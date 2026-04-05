CREATE VIEW user_view_their_roles AS 
SELECT user_roles.role 
    FROM 
    user_roles JOIN profiles 
    ON
    user_roles.id = profiles.id;

CREATE OR REPLACE PROCEDURE add_session_role(
    p_role all_roles
) AS $$ RETURNS VOID
DECLARE  
    v_user_id UUID;
    v_expiry_time TIMESTAMP;
BEGIN
    
    v_user_id = auth.uid();

    IF NOT EXISTS (
        SELECT 1 FROM 
        user_roles
        WHERE id = v_user_id
        AND "role" = p_role
    ) THEN 
        RAISE EXCEPTION 'user has no such role';
    END IF;

    v_expiry_time := CASE p_role
        WHEN 'patient' THEN(now() + INTERVAL '7 days')
        WHEN 'doctor' THEN (now() + INTERVAL '8 hours')
        WHEN 'nurse' THEN (now() + INTERVAL '1 day')
        WHEN 'db_admin' THEN(now() + INTERVAL '3 days')
        WHEN 'hospital_manager' THEN(now() + INTERVAL '8 hours')
        WHEN 'pharmacist' THEN (now()+ INTERVAL '8 hours')
    END;

    INSERT INTO active_users_role("user_id", "role", expiry_time)
    VALUES (v_user_id, p_role, v_expiry_time)
    ON CONFLICT ("user_id") DO UPDATE SET 
    "role" = p_role,
    expiry_time = v_expiry_time;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION refresh_jwt_token(event jsonb)
RETURNS jsonb AS $$
DECLARE
    original_claims jsonb;
    v_user_id UUID;
    v_session_id UUID;
    v_role TEXT;
    v_role_assigned all_roles;
    v_expiry_time TIMESTAMP;
    v_expiry_time_UNIX BIGINT;
BEGIN
    original_claims := event->'claims';

    v_user_id := (original_claims ->> 'sub')::UUID;
    v_session_id := (original_claims ->> 'session_id')::UUID;
    v_role := original_claims ->> 'role';

    IF v_role != 'authenticated' THEN 
        RAISE EXCEPTION 'user not authenticated';
    END IF;

    SELECT "role", expiry_time INTO v_role_assigned, v_expiry_time
    FROM active_users_role
    WHERE "user_id" = v_user_id
    FOR UPDATE; -- no 2 functions fired in parellel that can hurt the db or multi role bullshit

    IF v_expiry_time > now() THEN
        v_expiry_time_UNIX := (EXTRACT(EPOCH FROM v_expiry_time))::BIGINT;
    ELSE 
        RAISE EXCEPTION 'timed out, please logging in again!';
    END IF;

    original_claims := original_claims || jsonb_build_object(
        'role_assigned', v_role_assigned,
        'exp', v_expiry_time_UNIX
    );

    UPDATE active_users_role
    SET "session_id" = v_session_id
    WHERE "user_id" = v_user_id; --PK so i dont need to filter by role

    INSERT INTO audit_logs("action", happened_at, person_id, table_name, pk)
    VALUES ('user logged in', now(), v_user_id, 'active_users_role', v_user_id);

    RETURN jsonb(event, '{claims}', original_claims);

END;
$$ LANGUAGE plpgsql;

