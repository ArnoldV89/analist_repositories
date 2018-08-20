select COALESCE(ROUND(EXTRACT(epoch FROM now() - pg_last_xact_replay_timestamp())),0) AS lag_segundos;
