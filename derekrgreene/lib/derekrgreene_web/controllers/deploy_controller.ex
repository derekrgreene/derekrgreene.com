defmodule DerekrgreeneWeb.DeployController do
  use DerekrgreeneWeb, :controller
  require Logger
  
  plug :capture_raw_body



  def webhook(conn, _params) do
    # Try to get the raw body from the connection
    raw_body = conn.assigns[:raw_body] || ""
    
    # If no raw body, try to read it directly
    {body, conn_to_use} = if raw_body == "" do
      case read_body(conn) do
        {:ok, body, updated_conn} -> {body, updated_conn}
        {:error, _} -> {"", conn}
      end
    else
      {raw_body, conn}
    end
    
    # Verify GitHub webhook signature using the actual raw body
    case verify_webhook_signature(conn_to_use, body) do
      :ok ->
        # Get the GitHub webhook payload
        case get_req_header(conn_to_use, "x-github-event") do
          ["push"] ->
            handle_push_webhook(conn_to_use, body)
          _ ->
            conn_to_use
              |> put_status(:bad_request)
              |> json(%{error: "Invalid webhook event"})
        end
      :error ->
        conn_to_use
          |> put_status(:unauthorized)
          |> json(%{error: "Invalid webhook signature"})
    end
  end

  defp handle_push_webhook(conn, body) do
    case Jason.decode(body) do
      {:ok, payload} ->
        # Check if any commit message contains "PROD"
        if should_deploy?(payload) do
          # Trigger deployment
          spawn(fn -> trigger_deployment() end)
          
          conn
          |> put_status(:ok)
          |> json(%{message: "Deployment triggered", commits: get_commit_messages(payload)})
        else
          conn
          |> put_status(:ok)
          |> json(%{message: "No deployment needed", commits: get_commit_messages(payload)})
        end
      
      {:error, _} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Invalid JSON payload"})
    end
  end

  defp should_deploy?(payload) do
    case payload do
      %{"commits" => commits} when is_list(commits) ->
        Enum.any?(commits, fn commit ->
          case commit do
            %{"message" => message} when is_binary(message) ->
              String.contains?(String.upcase(message), "PROD")
            _ ->
              false
          end
        end)
      _ ->
        false
    end
  end

  defp get_commit_messages(payload) do
    case payload do
      %{"commits" => commits} when is_list(commits) ->
        Enum.map(commits, fn commit ->
          case commit do
            %{"message" => message, "id" => id} ->
              %{id: id, message: message}
            %{"message" => message} ->
              %{id: "unknown", message: message}
            _ ->
              %{id: "unknown", message: "No message"}
          end
        end)
      _ ->
        []
    end
  end

  defp verify_webhook_signature(conn, body) do
    # Check if GitHub secret is configured
    case System.get_env("GITHUB_SECRET") do
      nil ->
        Logger.error("GITHUB_SECRET environment variable not set")
        :error
      secret ->
        case get_req_header(conn, "x-hub-signature-256") do
          [signature] ->
            # Calculate expected signature
            expected_signature = "sha256=" <> Base.encode16(:crypto.mac(:hmac, :sha256, secret, body), case: :lower)
            
            # DEBUG: Log signature details
            Logger.info("Received signature: #{signature}")
            Logger.info("Expected signature: #{expected_signature}")
            Logger.info("Body: #{body}")
            Logger.info("Secret length: #{String.length(secret)}")
            Logger.info("Raw body length: #{String.length(body)}")
            Logger.info("Body first 100 chars: #{String.slice(body, 0, 100)}")
            
            if Plug.Crypto.secure_compare(signature, expected_signature) do
              :ok
            else
              :error
            end
          [] ->
            Logger.error("No x-hub-signature-256 header found")
            :error
          _ ->
            Logger.error("Invalid x-hub-signature-256 header format")
            :error
        end
    end
  end

  defp trigger_deployment() do
    script_path = Path.expand("~/scripts/phoenix_auto_deploy.sh")
    
    if File.exists?(script_path) do
      # Execute the deployment script
      case System.cmd("bash", [script_path], stderr_to_stdout: true) do
        {output, 0} ->
          Logger.info("Deployment script executed successfully: #{output}")
        {output, exit_code} ->
          Logger.error("Deployment script failed with exit code #{exit_code}: #{output}")
      end
    else
      Logger.error("Deployment script not found at: #{script_path}")
    end
  end

  # Plug function to capture raw body before Phoenix processes it
  defp capture_raw_body(conn, _opts) do
    case read_body(conn) do
      {:ok, body, conn} ->
        Logger.info("Raw body captured, length: #{String.length(body)}")
        assign(conn, :raw_body, body)
      {:error, _} ->
        Logger.error("Failed to read body")
        assign(conn, :raw_body, "")
    end
  end
end
