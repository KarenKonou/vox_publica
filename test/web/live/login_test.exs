defmodule VoxPublica.Web.LoginLive.Test do

  use VoxPublica.ConnCase
  alias VoxPublica.Accounts

  test "disconnected", %{conn: conn} do
    conn = get(conn, "/login")
    doc = floki_response(conn)
    assert [form] = Floki.find(doc, "#login-form")
    assert [_] = Floki.find(form, "#login-form_email")
    assert [_] = Floki.find(form, "#login-form_password")
    assert [_] = Floki.find(form, "button[type='submit']")
  end

  test "required fields", %{conn: conn} do
    {view, doc} = floki_live(conn, "/login")
    assert [form] = Floki.find(doc, "#login-form")
    assert [email_input] = Floki.find(form, "#login-form_email")
    assert [password_input] = Floki.find(form, "#login-form_password")
    assert [submit] = Floki.find(form, "button[type='submit']")
    doc = floki_submit(view, :submit, %{})
    assert [form] = Floki.find(doc, "#login-form")
    assert [_] = Floki.find(form, "#login-form_email")
    assert [email_error] = Floki.find(form, "span.invalid-feedback[phx-feedback-for='login-form_email']")
    assert "can't be blank" == Floki.text(email_error)
    assert [_] = Floki.find(form, "#login-form_password")
    assert [password_error] = Floki.find(form, "span.invalid-feedback[phx-feedback-for='login-form_password']")
    assert "can't be blank" == Floki.text(password_error)
    assert [_] = Floki.find(form, "button[type='submit']")
    email = Fake.email()
    password = Fake.password()
    doc = floki_submit(view, :submit, %{"email" => email})
    assert [form] = Floki.find(doc, "#login-form")
    assert [_] = Floki.find(form, "#login-form_email")
    assert [] == Floki.find(form, "span.invalid-feedback[phx-feedback-for='login-form_email']")
    assert [_] = Floki.find(form, "#login-form_password")
    assert [password_error] = Floki.find(form, "span.invalid-feedback[phx-feedback-for='login-form_password']")
    assert "can't be blank" == Floki.text(password_error)
    assert [_] = Floki.find(form, "button[type='submit']")
    doc = floki_submit(view, :submit, %{"password" => password})
    assert [form] = Floki.find(doc, "#login-form")
    assert [_] = Floki.find(form, "#login-form_email")
    assert [_] = Floki.find(form, "span.invalid-feedback[phx-feedback-for='login-form_email']")
    assert [_] = Floki.find(form, "#login-form_password")
    assert [] = Floki.find(form, "span.invalid-feedback[phx-feedback-for='login-form_password']")
    assert "can't be blank" == Floki.text(password_error)
    assert [_] = Floki.find(form, "button[type='submit']")
  end

  test "not found", %{conn: conn} do
    {view, _} = floki_live(conn, "/login")
    email = Fake.email()
    password = Fake.password()
    doc = floki_submit(view, :submit, %{"email" => email, "password" => password})
    assert [div] = Floki.find(doc, "div.error")
    assert [span] = Floki.find(div, "span")
    assert Floki.text(span) =~ ~r/incorrect/
    assert [] = Floki.find(doc, "#register-form")
  end

  test "not activated", %{conn: conn} do
    {view, _} = floki_live(conn, "/login")
    {:ok, account} = Accounts.register(Fake.account())
    params = %{"email" => account.email.email, "password" => account.login_credential.password}
    doc = floki_submit(view, :submit, params)
    assert [div] = Floki.find(doc, "div.error")
    assert [span] = Floki.find(div, "span")
    assert Floki.text(span) =~ ~r/confirm/
    assert [_] = Floki.find(doc, "#login-form")
  end

  test "success", %{conn: conn} do
    {view, _} = floki_live(conn, "/login")
    {:ok, account} = Accounts.register(Fake.account())
    {:ok, account} = Accounts.confirm_email(account)
    params = %{"email" => account.email.email, "password" => account.login_credential.password}
    assert {:error, {:live_redirect, %{kind: :push, to: "/home"}}} == render_submit(view, :submit, params)
  end


end
