{ pkgs, ... }:

{
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16;

    initialScript = pkgs.writeText "init.sql" ''
      CREATE DATABASE mydb;
      CREATE USER myuser WITH PASSWORD 'mypassword';
      GRANT ALL PRIVILEGES ON DATABASE mydb TO myuser;

      \\c mydb

      GRANT USAGE, CREATE ON SCHEMA public TO myuser;
      ALTER DEFAULT PRIVILEGES IN SCHEMA public
        GRANT ALL ON TABLES TO myuser;
    '';
  };
}
