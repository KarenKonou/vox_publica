defmodule VoxPublica.Repo.Migrations.ImportWorld do
  use Ecto.Migration

  import CommonsPub.Accounts.Account.Migration
  import CommonsPub.Accounts.Accounted.Migration
  import CommonsPub.Actors.Actor.Migration
  import CommonsPub.Characters.Character.Migration
  import CommonsPub.Circles.Circle.Migration
  import CommonsPub.Circles.Encircle.Migration
  import CommonsPub.Access.Access.Migration
  import CommonsPub.Access.AccessGrant.Migration
  import CommonsPub.Acls.Acl.Migration
  import CommonsPub.Acls.AclGrant.Migration
  import CommonsPub.Emails.Email.Migration
  import CommonsPub.LocalAuth.LoginCredential.Migration
  import CommonsPub.Profiles.Profile.Migration
  import CommonsPub.Users.User.Migration

  def change do
    # accounts
    migrate_account()
    migrate_accounted()
    migrate_circle()
    migrate_encircle()
    migrate_access()
    migrate_access_grant()
    migrate_acl()
    migrate_acl_grant()
    migrate_email()
    migrate_login_credential()
    # users
    migrate_user()
    migrate_character()
    migrate_profile()
    migrate_actor()
  end

end
