defmodule DerekrgreeneWeb.DeployController do
  use DerekrgreeneWeb, :controller
  require Logger



  def webhook(conn, _params) do
    case read_body(conn) do
      {:ok, raw_body, updated_conn} ->
        # Verify GitHub webhook signature using the actual raw body
        case verify_webhook_signature(updated_conn, raw_body) do
          :ok ->
            # Get the GitHub webhook payload
            case get_req_header(updated_conn, "x-github-event") do
              ["push"] ->
                handle_push_webhook(updated_conn, raw_body)
              _ ->
                updated_conn
                  |> put_status(:bad_request)
                  |> json(%{error: "Invalid webhook event"})
            end
          :error ->
            updated_conn
              |> put_status(:unauthorized)
              |> json(%{error: "Invalid webhook signature"})
        end
      {:error, _} ->
        conn
          |> put_status(:bad_request)
          |> json(%{error: "Failed to read request body"})
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
            expected_signature = "sha256=" <> (:crypto.mac(:hmac, :sha256, secret, body) |> Base.encode16(case: :lower))
            
            # DEBUG: Log signature details
            Logger.info("Received signature: #{signature}")
            Logger.info("Expected signature: #{expected_signature}")
            Logger.info("Body: #{body}")
            Logger.info("Secret length: #{String.length(secret)}")
            
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
end
