defmodule DerekrgreeneWeb.DeployController do
  use DerekrgreeneWeb, :controller
  require Logger

  def webhook(conn, _params) do
    case read_body(conn) do
      {:ok, body, updated_conn} ->
        case verify_webhook_signature(updated_conn, body) do
          :ok ->
            case get_req_header(updated_conn, "x-github-event") do
              ["push"] ->
                handle_push_webhook(updated_conn, body)
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
      {:error, reason} ->
        Logger.error("Failed to read request body: #{inspect(reason)}")
        conn
          |> put_status(:bad_request)
          |> json(%{error: "Failed to read request body"})
    end
  end

  defp handle_push_webhook(conn, json_body) do
    case Jason.decode(json_body) do
      {:ok, payload} ->
        if should_deploy?(payload) do
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
    case System.get_env("GITHUB_SECRET") do
      nil ->
        Logger.error("GITHUB_SECRET environment variable not set")
        :error
      secret ->
        case get_req_header(conn, "x-hub-signature-256") do
          [signature] ->
            expected_signature = "sha256=" <> Base.encode16(:crypto.mac(:hmac, :sha256, secret, body), case: :lower)
            
            if Plug.Crypto.secure_compare(signature, expected_signature) do
              :ok
            else
              Logger.error("GitHub webhook signature verification failed")
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
      env = [
        {"PATH", "/usr/local/bin:/usr/bin:/bin:/home/derek/.local/bin"},
        {"HOME", "/home/derek"},
        {"MIX_ENV", "prod"},
        {"USER", "derek"}
      ]
      
      case System.cmd("bash", [script_path], 
                     stderr_to_stdout: true, 
                     env: env,
                     cd: "/home/derek") do
        {output, 143} ->
          Logger.info("Deployment script executed successfully: #{output}")
        {output, exit_code} ->
          Logger.error("Deployment script failed with exit code #{exit_code}: #{output}")
      end
    else
      Logger.error("Deployment script not found at: #{script_path}")
    end
  end
end