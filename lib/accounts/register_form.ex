defmodule VoxPublica.Accounts.RegisterForm do

  use Ecto.Schema
  alias Ecto.Changeset
  alias VoxPublica.Accounts.RegisterForm

  embedded_schema do
    field :form, :string, virtual: true
    field :email, :string
    field :password, :string
  end

  @cast [:email, :password]
  @required @cast

  def changeset(form \\ %RegisterForm{}, attrs) do
    form
    |> Changeset.cast(attrs, @cast)
    |> Changeset.validate_required(@required)
    |> Changeset.validate_format(:email, ~r(^[^@]{1,128}@[^@\.]+\.[^@]{2,128}$))
    |> Changeset.validate_length(:password, min: 10)
  end

end
