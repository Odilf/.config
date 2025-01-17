{
  lib,
  pkgs,
  config,
  ...
}:
{
  /*
    Expands `set` for each user's home config.

    # Example

    ```nix
    {
      packages.users = [ "odilf" "gamer" ];

      config = eachHome {
        foo = "bar";
      };
    }
    ```

    Expands to:

    ```nix
    {
      config = home-manager.users = {
        odilf = {
          foo = "bar";
        };

        gamer = {
          foo = "bar";
        };
      };
    }
    ```
  */
  eachHome = set: {
    home-manager.users = builtins.listToAttrs (
      builtins.map (user: {
        name = user;
        value = set;
      }) config.packages.users
    );
  };
}
