DROP FUNCTION IF EXISTS F_CLEANDATE;
CREATE FUNCTION F_CLEANDATE(fecha VARCHAR(20), format VARCHAR(10)) RETURNS DATE
BEGIN

  DECLARE fecha_out DATE DEFAULT DATE('1970-01-01');

  IF YEAR(fecha)!=0 THEN
    IF MONTH(fecha)=0 THEN
      SET fecha_out = MAKEDATE(YEAR(fecha),1);
    ELSE
       SET fecha_out = str_to_date(fecha,format);
    END IF;
  END IF;
  RETURN fecha_out;
END;