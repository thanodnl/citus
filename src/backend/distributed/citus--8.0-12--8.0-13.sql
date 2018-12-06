/* citus--8.0-12--8.0-13 */
CREATE FUNCTION citus_reset_default_for_node_conninfo()
    RETURNS void
    LANGUAGE C STRICT
    AS 'MODULE_PATHNAME', $$citus_reset_default_for_node_conninfo$$;

DO LANGUAGE plpgsql
$$
BEGIN
    -- Citus 8.1 and higher default to requiring SSL for all outgoing connections
    -- (specified by citus.node_conninfo).
    -- If it looks like we are about to enforce ssl for outgoing connections on a postgres
    -- installation that do not have ssl turned on we fall back to sslmode=prefer.
    -- This will only be the case for upgrades from previous versions of Citus, on new
    -- installations we will have turned on ssl in an earlier stage of the extension
    -- creation.
    IF
        NOT current_setting('ssl')::boolean
		AND current_setting('citus.node_conninfo') = 'sslmode=require'
	THEN
	    PERFORM citus_reset_default_for_node_conninfo();
	END IF;
END;
$$;

DROP FUNCTION citus_reset_default_for_node_conninfo();