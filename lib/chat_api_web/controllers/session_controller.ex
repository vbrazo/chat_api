defmodule ChatApiWeb.SessionController do
  use ChatApiWeb, :controller

  alias ChatApi.Authentication.Auth

  action_fallback(ChatApiWeb.FallbackController)

  def create(conn, params) do
    case Auth.find_user_and_check_password(params) do
      {:ok, user} ->
        {:ok, jwt, _full_claims} =
          user |> ChatApiWeb.Guardian.encode_and_sign(%{}, token_type: :token)

        conn
        |> put_status(:created)
        |> render(ChatApiWeb.UserView, "sign_in.json", jwt: jwt, user: user)

      {:error, message} ->
        conn
        |> put_status(401)
        |> render(ChatApiWeb.UserView, "error.json", message: message)
    end
  end

  def auth_error(conn, {_type, _reason}, _opts) do
    conn
    |> put_status(:forbidden)
    |> render(ChatApiWeb.UserView, "error.json", message: "Not Authenticated")
  end
end
