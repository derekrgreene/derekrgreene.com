defmodule DerekrgreeneWeb.DeployController do
  use DerekrgreeneWeb, :controller
  require Logger

  def webhook(conn, _params) do
    # Log request details for debugging
    Logger.info("Request method: #{conn.method}")
    Logger.info("Request path: #{conn.request_path}")
    Logger.info("Content-Type header: #{get_req_header(conn, "content-type")}")
    Logger.info("Content-Length header: #{get_req_header(conn, "content-length")}")
    
    # Check if body is already consumed
    Logger.info("conn.assigns keys: #{Map.keys(conn.assigns)}")
    Logger.info("conn.body_params: #{inspect(conn.body_params)}")
    Logger.info("conn.params: #{inspect(conn.params)}")
    
    # Try to read body with detailed logging
    Logger.info("About to call read_body...")
    case read_body(conn) do
      {:ok, body, updated_conn} ->
        Logger.info("Successfully read body, length: #{String.length(body)}")
        Logger.info("Body is binary: #{is_binary(body)}")
        Logger.info("Body is empty: #{body == ""}")
        Logger.info("Body first 50 chars: #{String.slice(body, 0, 50)}")
        
        # Manual HMAC test with hardcoded secret
        test_secret = "7c60472a-caa0-48d1-a912-32d0c556ea35"
        
        # Test with known values to verify HMAC calculation
        known_secret = "test_secret"
        known_body = "test_body"
        
        # Calculate the expected signature manually to verify our test
        known_hmac = :crypto.mac(:hmac, :sha256, known_secret, known_body)
        known_expected = "sha256=" <> Base.encode16(known_hmac, case: :lower)
        Logger.info("Manual calculation of expected: #{known_expected}")
        
        known_calculated = "sha256=" <> Base.encode16(:crypto.mac(:hmac, :sha256, known_secret, known_body), case: :lower)
        Logger.info("Known HMAC test: #{known_calculated} (expected: #{known_expected})")
        Logger.info("Known HMAC test passed: #{known_calculated == known_expected}")
        
        manual_signature = "sha256=" <> Base.encode16(:crypto.mac(:hmac, :sha256, test_secret, body), case: :lower)
        Logger.info("Manual HMAC test - Secret: #{test_secret}")
        Logger.info("Manual HMAC test - Body length: #{String.length(body)}")
        Logger.info("Manual HMAC test - Calculated signature: #{manual_signature}")
        
        # Verify GitHub webhook signature using the raw body
        case verify_webhook_signature(updated_conn, body) do
          :ok ->
            # Get the GitHub webhook payload
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
        Logger.error("Failed to read body: #{inspect(reason)}")
        conn
          |> put_status(:bad_request)
          |> json(%{error: "Failed to read request body"})
    end
  end

  defp handle_push_webhook(conn, json_body) do
    case Jason.decode(json_body) do
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
            # Test signature calculation with known values
            test_secret = "test_secret"
            test_body = "test_body"
            test_signature = "sha256=" <> Base.encode16(:crypto.mac(:hmac, :sha256, test_secret, test_body), case: :lower)
            Logger.info("Test signature calculation: secret='#{test_secret}', body='#{test_body}' -> #{test_signature}")
            
            # Log the actual secret and body being used
            Logger.info("Actual secret: '#{secret}'")
            Logger.info("Actual body (first 200 chars): '#{String.slice(body, 0, 200)}'")
            Logger.info("Actual body (last 200 chars): '#{String.slice(body, -200..-1)}'")
            
            # Calculate expected signature
            expected_signature = "sha256=" <> Base.encode16(:crypto.mac(:hmac, :sha256, secret, body), case: :lower)
            
            # DEBUG: Log signature details
            Logger.info("Received signature: #{signature}")
            Logger.info("Expected signature: #{expected_signature}")
            Logger.info("Body length: #{String.length(body)}")
            Logger.info("Secret length: #{String.length(secret)}")
            Logger.info("Body first 100 chars: #{String.slice(body, 0, 100)}")
            Logger.info("Body last 100 chars: #{String.slice(body, -100..-1)}")
            Logger.info("Body bytes: #{inspect(body, limit: 200)}")
            Logger.info("Body contains newlines: #{String.contains?(body, "\n")}")
            Logger.info("Body contains carriage returns: #{String.contains?(body, "\r")}")
            
            if Plug.Crypto.secure_compare(signature, expected_signature) do
              Logger.info("Signature verification successful")
              :ok
            else
              Logger.error("Signature verification failed")
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
