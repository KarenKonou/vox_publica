defmodule VoxPublica.ActivityPub.Adapter do
  @behaviour ActivityPub.Adapter

  alias ActivityPub.Actor
  alias VoxPublica.Users
  alias VoxPublica.Repo

  defp format_actor(user) do
    ap_base_path = System.get_env("AP_BASE_PATH", "/pub")
    id = VoxPublica.Web.Endpoint.url() <> ap_base_path <> "/actors/#{user.character.username}"

    data = %{
      "type" => "Person",
      "id" => id,
      "inbox" => "#{id}/inbox",
      "outbox" => "#{id}/outbox",
      "followers" => "#{id}/followers",
      "following" => "#{id}/following",
      "preferredUsername" => user.character.username,
      "name" => user.profile.name,
      "summary" => Map.get(user.profile, :summary)
    }

    %Actor{
      id: user.id,
      data: data,
      keys: user.actor.signing_key,
      local: true,
      ap_id: id,
      pointer_id: user.id,
      username: user.character.username,
      deactivated: false
    }
  end

  def get_actor_by_username(username) do
    with {:ok, user} <- Users.by_username(username),
         actor <- format_actor(user) do
      {:ok, actor}
    else
      _ -> {:error, :not_found}
    end
  end

  def update_local_actor(actor, params) do
    with {:ok, user} <- Users.by_username(actor.username),
         {:ok, user} <- Users.update(user, Map.put(params, :signing_key, params.keys)),
         actor <- format_actor(user) do
      {:ok, actor}
    end
  end

  def maybe_create_remote_actor(actor) do
    case Users.by_username(actor.username) do
      {:ok, _} -> :ok
      {:error, _} -> create_remote_actor(actor)
    end
  end

  def create_remote_actor(actor) do
    attrs = %{
      name: actor.data["name"],
      username: actor.username,
      summary: actor.data["summary"]
    }

    actor_object = ActivityPub.Object.get_by_ap_id(actor.ap_id)

    Repo.transact_with(fn ->
      with {:ok, user} <- Users.create_remote(attrs),
           {:ok, _object} <- ActivityPub.Object.update(actor_object, %{pointer_id: user.id}) do
        {:ok, user}
      end
    end)
  end
end
