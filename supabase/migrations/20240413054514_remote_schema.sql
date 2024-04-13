
SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

CREATE EXTENSION IF NOT EXISTS "pg_net" WITH SCHEMA "extensions";

CREATE EXTENSION IF NOT EXISTS "pgsodium" WITH SCHEMA "pgsodium";

CREATE SCHEMA IF NOT EXISTS "supabase_migrations";

ALTER SCHEMA "supabase_migrations" OWNER TO "postgres";

CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";

CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";

CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";

CREATE EXTENSION IF NOT EXISTS "pgjwt" WITH SCHEMA "extensions";

CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";

CREATE OR REPLACE FUNCTION "public"."is_member"("user_id" "uuid") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $_$
begin
  RETURN(select (EXISTS ( SELECT 1
   FROM members
  WHERE ((members.id = ( SELECT identities.provider_id
           FROM auth.identities
          WHERE ((identities.user_id = $1) AND (identities.provider = 'discord'::text)))) AND (members.joined = true)))));
end;
$_$;

ALTER FUNCTION "public"."is_member"("user_id" "uuid") OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";

CREATE TABLE IF NOT EXISTS "public"."intros" (
    "id" "text" NOT NULL,
    "sound" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);

ALTER TABLE "public"."intros" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."members" (
    "id" "text" NOT NULL,
    "username" "text" NOT NULL,
    "global_name" "text",
    "avatar" "text" NOT NULL,
    "banner" "text",
    "accent_color" integer,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "joined" boolean DEFAULT true NOT NULL
);

ALTER TABLE "public"."members" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."sounds" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "thumbnail" "uuid" NOT NULL,
    "audio" "uuid" NOT NULL,
    "author" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);

ALTER TABLE "public"."sounds" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "supabase_migrations"."schema_migrations" (
    "version" "text" NOT NULL,
    "statements" "text"[],
    "name" "text"
);

ALTER TABLE "supabase_migrations"."schema_migrations" OWNER TO "postgres";

ALTER TABLE ONLY "public"."intros"
    ADD CONSTRAINT "intros_id_key" UNIQUE ("id");

ALTER TABLE ONLY "public"."intros"
    ADD CONSTRAINT "intros_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."sounds"
    ADD CONSTRAINT "sounds_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."members"
    ADD CONSTRAINT "users_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."members"
    ADD CONSTRAINT "users_username_key" UNIQUE ("username");

-- ALTER TABLE ONLY "supabase_migrations"."schema_migrations"
--     ADD CONSTRAINT "schema_migrations_pkey" PRIMARY KEY ("version");

ALTER TABLE ONLY "public"."intros"
    ADD CONSTRAINT "public_intros_id_fkey" FOREIGN KEY ("id") REFERENCES "public"."members"("id") ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY "public"."intros"
    ADD CONSTRAINT "public_intros_sound_fkey" FOREIGN KEY ("sound") REFERENCES "public"."sounds"("id") ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY "public"."sounds"
    ADD CONSTRAINT "public_sounds_author_fkey" FOREIGN KEY ("author") REFERENCES "public"."members"("id") ON UPDATE CASCADE;

CREATE POLICY "Enable all access for members" ON "public"."intros" TO "authenticated" USING ("public"."is_member"("auth"."uid"()));

CREATE POLICY "Enable read access for members" ON "public"."members" FOR SELECT TO "authenticated" USING ("public"."is_member"("auth"."uid"()));

CREATE POLICY "Enable read access for members" ON "public"."sounds" FOR SELECT TO "authenticated" USING ("public"."is_member"("auth"."uid"()));

ALTER TABLE "public"."intros" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."members" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."sounds" ENABLE ROW LEVEL SECURITY;

GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";

GRANT ALL ON FUNCTION "public"."is_member"("user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."is_member"("user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_member"("user_id" "uuid") TO "service_role";

GRANT ALL ON TABLE "public"."intros" TO "anon";
GRANT ALL ON TABLE "public"."intros" TO "authenticated";
GRANT ALL ON TABLE "public"."intros" TO "service_role";

GRANT ALL ON TABLE "public"."members" TO "anon";
GRANT ALL ON TABLE "public"."members" TO "authenticated";
GRANT ALL ON TABLE "public"."members" TO "service_role";

GRANT ALL ON TABLE "public"."sounds" TO "anon";
GRANT ALL ON TABLE "public"."sounds" TO "authenticated";
GRANT ALL ON TABLE "public"."sounds" TO "service_role";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "service_role";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "service_role";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "service_role";

RESET ALL;
