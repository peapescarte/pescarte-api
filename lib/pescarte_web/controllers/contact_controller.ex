defmodule PescarteWeb.ContactController do
  use PescarteWeb, :controller
  require Logger
  alias PescarteWeb.ContactForm

  def show(conn, _params) do
    changeset = ContactForm.changeset(%{})
    current_path = conn.request_path
    render(conn, :show, changeset: changeset, current_path: current_path, error_message: nil)
  end

  def send_email(conn, %{"contact_form" => contact_form_params}) do
    case ContactForm.apply_action_changeset(contact_form_params, :insert) do
      {:ok, contact_form} ->
        client = Resend.client(api_key: "RESEND_KEY")

        receiver_email =
          Application.fetch_env!(:pescarte, PescarteWeb.Controller)[:receiver_email]

        email_data = %{
          from: contact_form.sender_email,
          to: receiver_email,
          subject: contact_form.sender_option,
          html: """
          <p><strong>Nome:</strong> #{contact_form.sender_name}</p>
          <p><strong>Assunto:</strong> #{contact_form.sender_option}</p>
          <p><strong>Mensagem:</strong> #{contact_form.sender_message}</p>
          """
        }

        case Resend.Emails.send(client, email_data) do
          {:ok, email_response} ->
            Logger.info("""
            [#{__MODULE__}] ==> Sent email from contact form:
            RESPONSE: #{inspect(email_response, pretty: true)}
            LOG_UUID: #{Ecto.UUID.generate()}
            """)

            conn
            |> put_flash(:info, "Email enviado com sucesso!")

          {:error, reason} ->
            Logger.error("""
            [#{__MODULE__}] ==> Error sending email from contact form:
            REASON: #{inspect(reason, pretty: true)}
            LOG_UUID: #{Ecto.UUID.generate()}
            """)

            conn
            |> put_flash(:error, "Erro ao enviar email.")
        end

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Erro na validação do formulário.")
    end
  end
end