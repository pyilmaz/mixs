--
-- PostgreSQL database dump
--

-- Dumped from database version 9.2.4
-- Dumped by pg_dump version 9.2.4
-- Started on 2016-02-22 09:58:57 CET

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- TOC entry 9 (class 2615 OID 25661)
-- Name: gsc_db; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA gsc_db;


ALTER SCHEMA gsc_db OWNER TO postgres;

--
-- TOC entry 2709 (class 0 OID 0)
-- Dependencies: 9
-- Name: SCHEMA gsc_db; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA gsc_db IS 'The Genomic Standards Consortium database for definiton of the MIxS checklists and the mapping of the different metadata items of diferent database like e.g. Silva, megx.net,mg-rast to MIxS';


SET search_path = gsc_db, pg_catalog;

--
-- TOC entry 264 (class 1255 OID 25662)
-- Name: apply_rules(text); Type: FUNCTION; Schema: gsc_db; Owner: postgres
--

CREATE FUNCTION apply_rules(item text) RETURNS text
    LANGUAGE plpgsql
    AS $$
  DECLARE
     res text := item;
     rule renaming_rules;
  BEGIN

    FOR rule IN Select * from gsc_db.renaming_rules LOOP
       res := replace(res, rule.term, rule.target);
    END LOOP;

    RETURN res;
  END;
$$;


ALTER FUNCTION gsc_db.apply_rules(item text) OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 181 (class 1259 OID 25663)
-- Name: env_parameters; Type: TABLE; Schema: gsc_db; Owner: postgres; Tablespace: 
--

CREATE TABLE env_parameters (
    label text NOT NULL,
    param text NOT NULL,
    utime timestamp with time zone DEFAULT now() NOT NULL,
    ctime timestamp with time zone DEFAULT now() NOT NULL,
    pos integer DEFAULT 1 NOT NULL,
    definition text DEFAULT ''::text NOT NULL,
    requirement character(1) DEFAULT 'X'::bpchar
);


ALTER TABLE gsc_db.env_parameters OWNER TO postgres;

--
-- TOC entry 182 (class 1259 OID 25674)
-- Name: environmental_items; Type: TABLE; Schema: gsc_db; Owner: postgres; Tablespace: 
--

CREATE TABLE environmental_items (
    label text NOT NULL,
    expected_value text DEFAULT ''::text NOT NULL,
    definition text DEFAULT ''::text NOT NULL,
    utime timestamp with time zone DEFAULT now() NOT NULL,
    ctime timestamp with time zone DEFAULT now() NOT NULL,
    item text,
    expected_value_details text,
    occurrence text DEFAULT ''::text,
    syntax text DEFAULT ''::text,
    example text DEFAULT ''::text,
    help text DEFAULT ''::text NOT NULL,
    regexp text DEFAULT ''::text NOT NULL,
    old_syntax text,
    value_type text DEFAULT ''::text NOT NULL,
    epicollectable boolean DEFAULT false NOT NULL,
    preferred_unit text DEFAULT ''::text NOT NULL,
    CONSTRAINT environmental_parameters_occurrence_check CHECK ((occurrence ~ '[0-9]+|m'::text))
);


ALTER TABLE gsc_db.environmental_items OWNER TO postgres;

--
-- TOC entry 183 (class 1259 OID 25693)
-- Name: env_item_details; Type: VIEW; Schema: gsc_db; Owner: postgres
--

CREATE VIEW env_item_details AS
    SELECT p.item, env.label AS clist, env.requirement, p.expected_value, p.expected_value_details, p.value_type, p.syntax, p.occurrence, p.regexp, 'original_sample'::text AS sample_assoc, env.pos, p.example, p.help, p.label, CASE WHEN (env.definition = ''::text) THEN p.definition ELSE env.definition END AS definition, p.epicollectable FROM (environmental_items p JOIN env_parameters env ON ((env.param = p.label)));


ALTER TABLE gsc_db.env_item_details OWNER TO postgres;

--
-- TOC entry 184 (class 1259 OID 25698)
-- Name: mixs_checklists; Type: TABLE; Schema: gsc_db; Owner: postgres; Tablespace: 
--

CREATE TABLE mixs_checklists (
    item text NOT NULL,
    label text DEFAULT ''::text NOT NULL,
    definition text DEFAULT ''::text NOT NULL,
    expected_value text DEFAULT ''::text NOT NULL,
    syntax text DEFAULT ''::text NOT NULL,
    example text DEFAULT ''::text NOT NULL,
    help text DEFAULT ''::text NOT NULL,
    occurrence text DEFAULT '1'::text NOT NULL,
    regexp text DEFAULT ''::text NOT NULL,
    section text DEFAULT ''::text NOT NULL,
    sample_assoc text DEFAULT ''::text NOT NULL,
    eu character(1),
    ba character(1),
    pl character(1),
    vi character(1),
    org character(1),
    me character(1),
    miens_s character(1),
    miens_c character(1),
    pos smallint DEFAULT 0 NOT NULL,
    ctime timestamp with time zone DEFAULT now() NOT NULL,
    utime timestamp with time zone DEFAULT now() NOT NULL,
    value_type text DEFAULT ''::text NOT NULL,
    expected_value_details text DEFAULT ''::text NOT NULL,
    epicollectable boolean DEFAULT false NOT NULL,
    preferred_unit text DEFAULT ''::text NOT NULL,
    CONSTRAINT mixs_checklists_occurence_check CHECK ((occurrence ~ '[0-9]+|m'::text))
);


ALTER TABLE gsc_db.mixs_checklists OWNER TO postgres;

--
-- TOC entry 2710 (class 0 OID 0)
-- Dependencies: 184
-- Name: TABLE mixs_checklists; Type: COMMENT; Schema: gsc_db; Owner: postgres
--

COMMENT ON TABLE mixs_checklists IS 'Overview table of MIGS checklist';


--
-- TOC entry 2711 (class 0 OID 0)
-- Dependencies: 184
-- Name: COLUMN mixs_checklists.label; Type: COMMENT; Schema: gsc_db; Owner: postgres
--

COMMENT ON COLUMN mixs_checklists.label IS 'Name of the MIGS/MIMS/MIENS descriptor';


--
-- TOC entry 2712 (class 0 OID 0)
-- Dependencies: 184
-- Name: COLUMN mixs_checklists.definition; Type: COMMENT; Schema: gsc_db; Owner: postgres
--

COMMENT ON COLUMN mixs_checklists.definition IS 'Definition of the semantics of the descriptor and maybe some information on how to use the field.';


--
-- TOC entry 2713 (class 0 OID 0)
-- Dependencies: 184
-- Name: COLUMN mixs_checklists.occurrence; Type: COMMENT; Schema: gsc_db; Owner: postgres
--

COMMENT ON COLUMN mixs_checklists.occurrence IS 'Number of time this descriptor can occure in a report';


--
-- TOC entry 2714 (class 0 OID 0)
-- Dependencies: 184
-- Name: COLUMN mixs_checklists.miens_s; Type: COMMENT; Schema: gsc_db; Owner: postgres
--

COMMENT ON COLUMN mixs_checklists.miens_s IS 'MIENS for marker gene surveys';


--
-- TOC entry 2715 (class 0 OID 0)
-- Dependencies: 184
-- Name: COLUMN mixs_checklists.miens_c; Type: COMMENT; Schema: gsc_db; Owner: postgres
--

COMMENT ON COLUMN mixs_checklists.miens_c IS 'MIENS for cultured organisms';


--
-- TOC entry 185 (class 1259 OID 25722)
-- Name: clist_item_details; Type: VIEW; Schema: gsc_db; Owner: postgres
--

CREATE VIEW clist_item_details AS
    (((((((SELECT mixs_checklists.item, 'eu'::text AS clist, mixs_checklists.eu AS requirement, mixs_checklists.expected_value, mixs_checklists.expected_value_details, mixs_checklists.value_type, mixs_checklists.syntax, mixs_checklists.occurrence, mixs_checklists.regexp, mixs_checklists.sample_assoc, mixs_checklists.pos, mixs_checklists.example, mixs_checklists.help, mixs_checklists.label, mixs_checklists.definition, mixs_checklists.epicollectable FROM mixs_checklists UNION SELECT mixs_checklists.item, 'ba'::text AS clist, mixs_checklists.ba AS requirement, mixs_checklists.expected_value, mixs_checklists.expected_value_details, mixs_checklists.value_type, mixs_checklists.syntax, mixs_checklists.occurrence, mixs_checklists.regexp, mixs_checklists.sample_assoc, mixs_checklists.pos, mixs_checklists.example, mixs_checklists.help, mixs_checklists.label, mixs_checklists.definition, mixs_checklists.epicollectable FROM mixs_checklists) UNION SELECT mixs_checklists.item, 'pl'::text AS clist, mixs_checklists.pl AS requirement, mixs_checklists.expected_value, mixs_checklists.expected_value_details, mixs_checklists.value_type, mixs_checklists.syntax, mixs_checklists.occurrence, mixs_checklists.regexp, mixs_checklists.sample_assoc, mixs_checklists.pos, mixs_checklists.example, mixs_checklists.help, mixs_checklists.label, mixs_checklists.definition, mixs_checklists.epicollectable FROM mixs_checklists) UNION SELECT mixs_checklists.item, 'vi'::text AS clist, mixs_checklists.vi AS requirement, mixs_checklists.expected_value, mixs_checklists.expected_value_details, mixs_checklists.value_type, mixs_checklists.syntax, mixs_checklists.occurrence, mixs_checklists.regexp, mixs_checklists.sample_assoc, mixs_checklists.pos, mixs_checklists.example, mixs_checklists.help, mixs_checklists.label, mixs_checklists.definition, mixs_checklists.epicollectable FROM mixs_checklists) UNION SELECT mixs_checklists.item, 'org'::text AS clist, mixs_checklists.org AS requirement, mixs_checklists.expected_value, mixs_checklists.expected_value_details, mixs_checklists.value_type, mixs_checklists.syntax, mixs_checklists.occurrence, mixs_checklists.regexp, mixs_checklists.sample_assoc, mixs_checklists.pos, mixs_checklists.example, mixs_checklists.help, mixs_checklists.label, mixs_checklists.definition, mixs_checklists.epicollectable FROM mixs_checklists) UNION SELECT mixs_checklists.item, 'me'::text AS clist, mixs_checklists.me AS requirement, mixs_checklists.expected_value, mixs_checklists.expected_value_details, mixs_checklists.value_type, mixs_checklists.syntax, mixs_checklists.occurrence, mixs_checklists.regexp, mixs_checklists.sample_assoc, mixs_checklists.pos, mixs_checklists.example, mixs_checklists.help, mixs_checklists.label, mixs_checklists.definition, mixs_checklists.epicollectable FROM mixs_checklists) UNION SELECT mixs_checklists.item, 'miens_s'::text AS clist, mixs_checklists.miens_s AS requirement, mixs_checklists.expected_value, mixs_checklists.expected_value_details, mixs_checklists.value_type, mixs_checklists.syntax, mixs_checklists.occurrence, mixs_checklists.regexp, mixs_checklists.sample_assoc, mixs_checklists.pos, mixs_checklists.example, mixs_checklists.help, mixs_checklists.label, mixs_checklists.definition, mixs_checklists.epicollectable FROM mixs_checklists) UNION SELECT mixs_checklists.item, 'miens_c'::text AS clist, mixs_checklists.miens_c AS requirement, mixs_checklists.expected_value, mixs_checklists.expected_value_details, mixs_checklists.value_type, mixs_checklists.syntax, mixs_checklists.occurrence, mixs_checklists.regexp, mixs_checklists.sample_assoc, mixs_checklists.pos, mixs_checklists.example, mixs_checklists.help, mixs_checklists.label, mixs_checklists.definition, mixs_checklists.epicollectable FROM mixs_checklists) UNION SELECT env_item_details.item, env_item_details.clist, env_item_details.requirement, env_item_details.expected_value, env_item_details.expected_value_details, env_item_details.value_type, env_item_details.syntax, env_item_details.occurrence, env_item_details.regexp, env_item_details.sample_assoc, env_item_details.pos, env_item_details.example, env_item_details.help, env_item_details.label, env_item_details.definition, env_item_details.epicollectable FROM env_item_details;


ALTER TABLE gsc_db.clist_item_details OWNER TO postgres;

--
-- TOC entry 2716 (class 0 OID 0)
-- Dependencies: 185
-- Name: VIEW clist_item_details; Type: COMMENT; Schema: gsc_db; Owner: postgres
--

COMMENT ON VIEW clist_item_details IS 'Details on contextual data items of the MIxS checklists.';


--
-- TOC entry 265 (class 1255 OID 25727)
-- Name: boolean2gcdmltype(clist_item_details); Type: FUNCTION; Schema: gsc_db; Owner: postgres
--

CREATE FUNCTION boolean2gcdmltype(item clist_item_details) RETURNS xml
    LANGUAGE plpgsql
    AS $$
  DECLARE
     res xml;
  BEGIN
     res := xmlelement(name "simpleType", 
                  xmlattributes(item.item || 'MIGSType' as name, '#all' as final), 
          xmlelement(name "annotation", 
             xmlelement(name "documentation", 
                        xmlattributes('en' as "xml:lang"), 
                        'Implementation of ' ||item.item || '. Defined as: ' || item.definition)),
          
             xmlelement(name restriction, 
                        xmlattributes('boolean' as base))
              );


     return res;
  END;
$$;


ALTER FUNCTION gsc_db.boolean2gcdmltype(item clist_item_details) OWNER TO postgres;

--
-- TOC entry 266 (class 1255 OID 25728)
-- Name: cd_items_b_trg(); Type: FUNCTION; Schema: gsc_db; Owner: postgres
--

CREATE FUNCTION cd_items_b_trg() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  /* Basically creates the cd_items.item entry
   * Does trimming, tranlating ' ' to '_' and lower case.
   *
   * @author rkottman@mpi-bremen.de
   */

  DECLARE

  BEGIN
    -- for both situations
    IF TG_OP = 'UPDATE' OR TG_OP = 'INSERT' THEN

      NEW.item := translate( lower(trim(NEW.item)), ' -', '__');
    END IF;

   RETURN NEW;
  END;
$$;


ALTER FUNCTION gsc_db.cd_items_b_trg() OWNER TO postgres;

--
-- TOC entry 2717 (class 0 OID 0)
-- Dependencies: 266
-- Name: FUNCTION cd_items_b_trg(); Type: COMMENT; Schema: gsc_db; Owner: postgres
--

COMMENT ON FUNCTION cd_items_b_trg() IS 'normalizes cd itme names';


--
-- TOC entry 267 (class 1255 OID 25729)
-- Name: create_migs_version(text, text); Type: FUNCTION; Schema: gsc_db; Owner: postgres
--

CREATE FUNCTION create_migs_version(ver_num text, message text) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
  DECLARE last_ver text;
  
  BEGIN
    -- get the last registered version
    SELECT INTO last_ver max(vers) 
      FROM (SELECT max(ver) as vers,max(cdate) 
              FROM migs_versions 
          GROUP BY cdate) as t; 
    --RAISE NOTICE 'Last version=%', last_ver;
    
    INSERT INTO migs_versions(ver,remark) VALUES (ver_num, message);
    --now creating snapshot for older existing version
    IF last_ver IS NOT NULL THEN
       INSERT INTO gsc_db.migs_snapshots(
            item, descr_name, descr, section, 
            eu, ba, pl, vi, org, me, miens_s, miens_c,
            help, definition, descr_text, miens_rational, 
            pos) 
             SELECT item, descr_name, descr, section, 
                    eu, ba, pl, vi, org, me, miens_s, miens_c,
                    help, definition, descr_text, miens_rational, 
                    pos, last_ver FROM migs_data;
    END IF;
    
    RETURN TRUE;
  END;
$$;


ALTER FUNCTION gsc_db.create_migs_version(ver_num text, message text) OWNER TO postgres;

--
-- TOC entry 268 (class 1255 OID 25730)
-- Name: encode_item(text); Type: FUNCTION; Schema: gsc_db; Owner: postgres
--

CREATE FUNCTION encode_item(item text) RETURNS text
    LANGUAGE plpgsql STABLE
    AS $$
  /* Basically creates the cd_items.item entry
   * Does trimming, translating ' /' to '_' and lower case.
   *
   * @author rkottman@mpi-bremen.de
   */

  DECLARE

  BEGIN
      return translate( lower(trim(item)), ' /-', '___');
  END;
$$;


ALTER FUNCTION gsc_db.encode_item(item text) OWNER TO postgres;

--
-- TOC entry 269 (class 1255 OID 25731)
-- Name: enum2gcdmltype(clist_item_details); Type: FUNCTION; Schema: gsc_db; Owner: postgres
--

CREATE FUNCTION enum2gcdmltype(item clist_item_details) RETURNS xml
    LANGUAGE plpgsql
    AS $$
  DECLARE
     res xml;
     enu xml;
  BEGIN
     enu := getEnumerationXML(item.syntax);

     res := xmlelement(name "simpleType", 
                  xmlattributes(item.item || 'MIGSType' as name, '#all' as final), 
          xmlelement(name "annotation", 
             xmlelement(name "documentation", 
                        xmlattributes('en' as "xml:lang"), 
                        'Implemantation of ' ||item.item || '. Defined as: ' || item.definition)),
          
             xmlelement(name restriction, 
                        xmlattributes('normalizedString' as base), enu)



              );

     return res;
  END;
$$;


ALTER FUNCTION gsc_db.enum2gcdmltype(item clist_item_details) OWNER TO postgres;

--
-- TOC entry 270 (class 1255 OID 25732)
-- Name: env2gcdmltypes(clist_item_details); Type: FUNCTION; Schema: gsc_db; Owner: postgres
--

CREATE FUNCTION env2gcdmltypes(item clist_item_details) RETURNS xml
    LANGUAGE plpgsql
    AS $$

  DECLARE
     res xml;
  BEGIN
     
     IF item.value_type IN ('measurement', 'named measurement') THEN
       res := measurement2gcdmlType(item);
     ELSIF item.value_type = 'text' THEN
       res := text2gcdmlType(item);
     ELSIF item.value_type = 'enumeration' THEN
       res := enum2gcdmlType(item);
     ELSIF item.value_type = 'reference' THEN
       res := reference2gcdmlType(item);
     ELSIF item.value_type IN ('regime', 'named regime') THEN
       res := regime2gcdmlType(item);
     ELSIF item.value_type = 'treatment' THEN
       res := treatment2gcdmlType(item);
     ELSIF item.value_type IN ('integer') THEN
       res := integer2gcdmlType(item);
     ELSIF item.value_type = 'boolean' THEN
       res := boolean2gcdmlType(item);
     ELSIF item.value_type = 'timestamp' THEN
       res := timestamp2gcdmlType(item);
     ELSE
       --res := xmlelement(name "not_implemented",
         --                xmlattributes(item.item as name)
           --              );
     END IF;

     return res;
  END;
$$;


ALTER FUNCTION gsc_db.env2gcdmltypes(item clist_item_details) OWNER TO postgres;

--
-- TOC entry 271 (class 1255 OID 25733)
-- Name: get_migs_pos(text, smallint, text); Type: FUNCTION; Schema: gsc_db; Owner: postgres
--

CREATE FUNCTION get_migs_pos(item text, newpos smallint, command text) RETURNS smallint
    LANGUAGE plpgsql
    AS $$
  DECLARE
    max_pos smallint;
    oldy_pos smallint;
    mpos smallint := newpos;
  BEGIN
    SELECT INTO max_pos maxpos FROM max_ordering;
    
    IF (mpos >= max_pos OR mpos <= 0) THEN
       mpos := COALESCE(max_pos, 0);
       IF (command = 'INSERT') THEN 
          mpos := mpos + 1;
          --RAISE NOTICE 'item=%,pos= %,MAX NUM=%', item,mpos,max_pos;
       END IF;
       
    END IF;
    
    IF (command = 'UPDATE') THEN 
    --RAISE NOTICE 'item=%,mpos= %,MAX NUM=%, command=%', item,mpos,max_pos,command;
      --update entry 
      UPDATE migs_pos SET opos = pos
       WHERE descr_name = item RETURNING opos INTO oldy_pos; 
      
      UPDATE migs_pos SET pos = mpos
       WHERE descr_name = item;

       IF (mpos < oldy_pos OR mpos = 1)  THEN
         -- UP shift all entries >= actual postion by one
         --RAISE NOTICE 'upshifting';
          UPDATE migs_pos SET opos = pos, pos = pos + 1 
           WHERE pos >= mpos AND descr_name != item AND pos < max_pos AND (pos < oldy_pos OR opos = 0 );
       END IF;

       IF (mpos > oldy_pos AND oldy_pos != 0) THEN
         -- DOWN shift all entries <= actual postion by one unil old position is reached
         --RAISE NOTICE 'downshifting';
         UPDATE migs_pos SET opos = pos, pos = pos - 1
          WHERE migs_pos.pos <= mpos 
            AND migs_pos.descr_name != item 
            AND migs_pos.pos > oldy_pos AND migs_pos.opos != 0;
        END IF;
     END IF;

     IF (command = 'INSERT') THEN 
     --RAISE NOTICE 'hello';
      
        INSERT INTO migs_pos (descr_name, pos, opos) VALUES (item, mpos, 0);
        
        UPDATE migs_pos SET opos = pos,pos = migs_pos.pos + 1
         WHERE migs_pos.pos >= mpos AND migs_pos.descr_name != item;
        --update max entry num
        UPDATE max_ordering SET maxpos = (max_ordering.maxpos + 1);
     END IF;



    --RETURN pos FROM migs_pos WHERE descr_name = item;
    RETURN mpos;
  END;
$$;


ALTER FUNCTION gsc_db.get_migs_pos(item text, newpos smallint, command text) OWNER TO postgres;

--
-- TOC entry 272 (class 1255 OID 25734)
-- Name: getenumerationxml(text); Type: FUNCTION; Schema: gsc_db; Owner: postgres
--

CREATE FUNCTION getenumerationxml(enu text) RETURNS xml
    LANGUAGE plpgsql
    AS $$
  DECLARE
     r record;
     res xml;
  BEGIN

       FOR r IN SELECT trim(regexp_split_to_table(trim(enu, '[]'), E'\\|'), ' ') AS part LOOP
         res := xmlconcat(res, xmlelement(name "enumeration", xmlattributes( r.part as value)));
       END LOOP;
     return res;
  END;
$$;


ALTER FUNCTION gsc_db.getenumerationxml(enu text) OWNER TO postgres;

--
-- TOC entry 273 (class 1255 OID 25735)
-- Name: integer2gcdmltype(clist_item_details); Type: FUNCTION; Schema: gsc_db; Owner: postgres
--

CREATE FUNCTION integer2gcdmltype(item clist_item_details) RETURNS xml
    LANGUAGE plpgsql
    AS $$
  DECLARE
     res xml;
  BEGIN
     res := xmlelement(name "simpleType", 
                  xmlattributes(item.item || 'MIGSType' as name, '#all' as final), 
          xmlelement(name "annotation", 
             xmlelement(name "documentation", 
                        xmlattributes('en' as "xml:lang"), 
                        'Implementation of ' ||item.item || '. Defined as: ' || item.definition)),
          
             xmlelement(name restriction, 
                        xmlattributes('integer' as base))
              );


     return res;
  END;
$$;


ALTER FUNCTION gsc_db.integer2gcdmltype(item clist_item_details) OWNER TO postgres;

--
-- TOC entry 274 (class 1255 OID 25736)
-- Name: measurement2gcdmltype(clist_item_details); Type: FUNCTION; Schema: gsc_db; Owner: postgres
--

CREATE FUNCTION measurement2gcdmltype(item clist_item_details) RETURNS xml
    LANGUAGE plpgsql STABLE STRICT
    SET search_path TO gsc_db, public
    AS $$

  DECLARE
     res xml;
     valAtt xml := xmlelement(name attribute, xmlattributes('values' as name,
                                                         'gcdml:positiveDoubleList' as type,
                                                         'required' as use));
    uomType text := 'token';

    restrictionPrefix text := CASE WHEN item.value_type = 'named measurement' 
                                   THEN 'gcdml:NamedMeasurement' 
                                   ELSE 'gcdml:Measurement' END; 
    
  BEGIN

  res := xmlconcat(
         xmlelement(name "complexType", 
                  xmlattributes(item.item || 'MIGSType' as name, '#all' as final), 
          xmlelement(name "annotation", 
             xmlelement(name "documentation", 
                              xmlattributes('en' as "xml:lang"), 
                              'Implemantation of ' ||item.item || '. Defined as: ' || item.definition)),
          xmlelement(name "complexContent", 
             xmlelement(name restriction, 
                        xmlattributes(restrictionPrefix || 'MIGSType' as base),
                
                xmlelement(name attribute, xmlattributes('uom' as "name",
                                                         uomType as type,
                                                         'required' as use))
             )
          )
       ),
       -- now GCD version

        xmlelement(name "complexType", 
                  xmlattributes(item.item || 'Type' as name, '#all' as final), 
          xmlelement(name "annotation", 
             xmlelement(name "documentation", xmlattributes('en' as "xml:lang"), 
                                                 'GCD implementation with additional attributes. ' || item.definition)),
          xmlelement(name "complexContent", 
             xmlelement(name restriction, 
                        xmlattributes(restrictionPrefix || 'Type' as base),
                xmlelement(name attribute, xmlattributes('uom' as "name",
                                                         uomType as type,
                                                         'required' as use))
             )
          )
       )-- end second xml
     ); -- end xmlconcat


     return res;
  END;
$$;


ALTER FUNCTION gsc_db.measurement2gcdmltype(item clist_item_details) OWNER TO postgres;

--
-- TOC entry 275 (class 1255 OID 25737)
-- Name: mixs2epicollect(clist_item_details); Type: FUNCTION; Schema: gsc_db; Owner: postgres
--

CREATE FUNCTION mixs2epicollect(item clist_item_details) RETURNS xml
    LANGUAGE plpgsql
    AS $$

  DECLARE
     res xml;
  BEGIN
     
     IF item.value_type IN ('measurement', 'named measurement', 'text') THEN
       res := mixs2epicollectInput(item);
     ELSIF item.value_type = 'enumeration' THEN
       res := mixs2epicollectInput(item);
     ELSIF item.value_type = 'reference' THEN
       res := mixs2epicollectInput(item);

     ELSIF item.value_type IN ('regime', 'named regime') THEN
       res := mixs2epicollectInput(item);

     ELSIF item.value_type = 'treatment' THEN
       res := mixs2epicollectInput(item);

     ELSIF item.value_type IN ('integer') THEN
       res := mixs2epicollectInput(item);

     ELSIF item.value_type = 'boolean' THEN
       res := mixs2epicollectInput(item);
     
     ELSIF item.value_type = 'timestamp' THEN
       res := mixs2epicollectInput(item);
     
     ELSE
       res := mixs2epicollectInput(item);
     
     END IF;

     return res;
  END;
$$;


ALTER FUNCTION gsc_db.mixs2epicollect(item clist_item_details) OWNER TO postgres;

--
-- TOC entry 276 (class 1255 OID 25738)
-- Name: mixs2epicollectinput(clist_item_details); Type: FUNCTION; Schema: gsc_db; Owner: postgres
--

CREATE FUNCTION mixs2epicollectinput(item clist_item_details) RETURNS xml
    LANGUAGE plpgsql
    AS $$

  DECLARE
     res xml;
     empty xml := xmlcomment(item.item || ' not implemented yet');

     label_elem xml := xmlelement(name "label",
                                  item.label
                                  );

     unit_elem xml := xmlelement(name "input", 
                      xmlattributes( item.item || '_uom' as ref,
                                     'true' as required
                                     ),
                       xmlelement(name "label", 'unit of measurement')
                      );

     text_elem xml := xmlelement(name "input", 
                      xmlattributes( item.item as ref,
                                     CASE WHEN item.requirement = 'M'
                                          THEN 'true'
                                          ELSE 'false' END as required
                                     ),
                       label_elem
                      );

     num_elem xml := xmlelement(name "input", 
                      xmlattributes( item.item as ref,
                                     CASE WHEN item.requirement = 'M'
                                          THEN 'true'
                                          ELSE 'false' END as required,
                                     'true' as numeric
                                     ),
                       label_elem
                      ); 
  BEGIN
    

     IF item.value_type = 'text' THEN
       res := text_elem;
     ELSIF item.value_type = 'measurement' THEN
       res := xmlconcat(num_elem, unit_elem);
     ELSIF item.value_type = 'named measurement' THEN
       res :=  xmlconcat(text_elem, num_elem, unit_elem);
     ELSIF item.value_type = 'enumeration' THEN
       res := empty;
     ELSIF item.value_type = 'reference' THEN
       res := text_elem;

     ELSIF item.value_type IN ('regime', 'named regime') THEN
       res := empty;

     ELSIF item.value_type = 'treatment' THEN
       res := empty;

     ELSIF item.value_type = 'integer' THEN
       res := num_elem;

     ELSIF item.value_type = 'boolean' THEN
       -- selection
       res := empty;
     
     ELSIF item.value_type = 'timestamp' THEN
       res := empty;
     
     ELSE
       res := empty;
     
     END IF;



     return res;
  END;
$$;


ALTER FUNCTION gsc_db.mixs2epicollectinput(item clist_item_details) OWNER TO postgres;

--
-- TOC entry 277 (class 1255 OID 25739)
-- Name: prettyprintxml(xml); Type: FUNCTION; Schema: gsc_db; Owner: postgres
--

CREATE FUNCTION prettyprintxml(con xml) RETURNS text
    LANGUAGE plpgsql STABLE STRICT
    SET search_path TO public, gsc_db
    AS $$

  DECLARE
    xmlc text;
    r RECORD;
    res text := '';
  BEGIN
   xmlc := XMLSERIALIZE ( CONTENT con AS text );

   FOR r IN select regexp_replace(xmlc, E'(<[^>]*>)', E'\\1\n','gi') as part LOOP
     res := res || r.part;
   END LOOP;



     return res;
  END;
$$;


ALTER FUNCTION gsc_db.prettyprintxml(con xml) OWNER TO postgres;

--
-- TOC entry 278 (class 1255 OID 25740)
-- Name: process_migs_change(); Type: FUNCTION; Schema: gsc_db; Owner: postgres
--

CREATE FUNCTION process_migs_change() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO gsc_db, public
    AS $$
  DECLARE
    --max_pos smallint;
  BEGIN

    IF NEW.section IS NOT NULL THEN
      NEW.section := lower(NEW.section);
    END IF;

    IF (TG_OP = 'INSERT') THEN 
    
       PERFORM get_migs_pos(NEW.item, NEW.pos, 'INSERT');
    END IF;
    IF (TG_OP = 'UPDATE') THEN 
       PERFORM get_migs_pos(old.item, NEW.pos, 'UPDATE');
       
    END IF;
   
    RETURN NEW;
  END;
$$;


ALTER FUNCTION gsc_db.process_migs_change() OWNER TO postgres;

--
-- TOC entry 279 (class 1255 OID 25741)
-- Name: reference2gcdmltype(clist_item_details); Type: FUNCTION; Schema: gsc_db; Owner: postgres
--

CREATE FUNCTION reference2gcdmltype(item clist_item_details) RETURNS xml
    LANGUAGE plpgsql
    AS $$
  DECLARE
     res xml;
  BEGIN

     res := xmlelement(name "complexType", 
                  xmlattributes(item.item || 'MIGSType' as name, '#all' as final), 
          xmlelement(name "annotation", 
             xmlelement(name "documentation", 
                        xmlattributes('en' as "xml:lang"), 
                        'Implemantation of ' ||item.item || '. Defined as: ' ||item.definition)),
          
             xmlelement(name "complexContent",
                xmlelement(name "extension",
                        xmlattributes('gcdml:litReferenceType' as base)))

              );

     return res;
  END;
$$;


ALTER FUNCTION gsc_db.reference2gcdmltype(item clist_item_details) OWNER TO postgres;

--
-- TOC entry 280 (class 1255 OID 25742)
-- Name: regime2gcdmltype(clist_item_details); Type: FUNCTION; Schema: gsc_db; Owner: postgres
--

CREATE FUNCTION regime2gcdmltype(item clist_item_details) RETURNS xml
    LANGUAGE plpgsql STABLE STRICT
    SET search_path TO gsc_db, public
    AS $$

  DECLARE
     res xml;
     groupElem xml := xmlelement(name "group", 
                                 xmlattributes('gcdml:RegimeTimesGroup' as "ref")
                                 );
    uomType text := 'token';

    restrictionPrefix text := CASE WHEN item.value_type = 'named regime' 
                                   THEN 'gcdml:NamedRegimeMeasurement' 
                                   ELSE 'gcdml:RegimeMeasurement' END; 
    
  BEGIN

  res := xmlconcat(
         xmlelement(name "complexType", 
                  xmlattributes(item.item || 'MIGSType' as name, '#all' as final), 
          xmlelement(name "annotation", 
             xmlelement(name "documentation", 
                              xmlattributes('en' as "xml:lang"), 
                              'Implemantation of ' ||item.item || '. Defined as: ' || item.definition)),
          xmlelement(name "complexContent", 
             xmlelement(name restriction, 
                        xmlattributes(restrictionPrefix || 'MIGSType' as base),
                groupElem,
                xmlelement(name attribute, xmlattributes('uom' as "name",
                                                         uomType as type,
                                                         'required' as use))
             )
          )
       ),
       -- now GCD version

        xmlelement(name "complexType", 
                  xmlattributes(item.item || 'Type' as name, '#all' as final), 
          xmlelement(name "annotation", 
             xmlelement(name "documentation", xmlattributes('en' as "xml:lang"), 
                                                 'GCD implementation with additional attributes. ' || item.definition)),
          xmlelement(name "complexContent", 
             xmlelement(name restriction, 
                        xmlattributes(restrictionPrefix || 'Type' as base),
                 groupElem,
                xmlelement(name attribute, xmlattributes('uom' as "name",
                                                         uomType as type,
                                                         'required' as use))
             )
          )
       )-- end second xml
     ); -- end xmlconcat


     return res;
  END;
$$;


ALTER FUNCTION gsc_db.regime2gcdmltype(item clist_item_details) OWNER TO postgres;

--
-- TOC entry 281 (class 1255 OID 25743)
-- Name: text2gcdmltype(clist_item_details); Type: FUNCTION; Schema: gsc_db; Owner: postgres
--

CREATE FUNCTION text2gcdmltype(item clist_item_details) RETURNS xml
    LANGUAGE plpgsql
    AS $$

  DECLARE
     res xml;
  BEGIN
     res := xmlelement(name "simpleType", 
                  xmlattributes(item.item || 'MIGSType' as name, '#all' as final), 
          xmlelement(name "annotation", 
             xmlelement(name "documentation", xmlattributes('en' as "xml:lang"), item.definition)),
          
             xmlelement(name restriction, 
                        xmlattributes('normalizedString' as base)));

     return res;
  END;
$$;


ALTER FUNCTION gsc_db.text2gcdmltype(item clist_item_details) OWNER TO postgres;

--
-- TOC entry 282 (class 1255 OID 25744)
-- Name: timestamp2gcdmltype(clist_item_details); Type: FUNCTION; Schema: gsc_db; Owner: postgres
--

CREATE FUNCTION timestamp2gcdmltype(item clist_item_details) RETURNS xml
    LANGUAGE plpgsql
    AS $$
  DECLARE
     res xml;
  BEGIN
     res := xmlelement(name "complexType", 
                  xmlattributes(item.item || 'MIGSType' as name, '#all' as final), 
          xmlelement(name "annotation", 
             xmlelement(name "documentation", 
                        xmlattributes('en' as "xml:lang"), 
                        'Implementation of ' ||item.item || '. Defined as: ' || item.definition)),
          
             xmlelement(name "attribute", 
                        xmlattributes('time' as name, 
                                      'gcdml:FuzzyTimePositionUnion' as type,
                                       'required' as use)
                       )
              );


     return res;
  END;
$$;


ALTER FUNCTION gsc_db.timestamp2gcdmltype(item clist_item_details) OWNER TO postgres;

--
-- TOC entry 283 (class 1255 OID 25745)
-- Name: treatment2gcdmltype(clist_item_details); Type: FUNCTION; Schema: gsc_db; Owner: postgres
--

CREATE FUNCTION treatment2gcdmltype(item clist_item_details) RETURNS xml
    LANGUAGE plpgsql STABLE STRICT
    SET search_path TO gsc_db, public
    AS $$

  DECLARE
     res xml;

  BEGIN

  res := xmlelement(name "complexType", 
                  xmlattributes(item.item || 'MIGSType' as name, '#all' as final), 
          xmlelement(name "annotation", 
             xmlelement(name "documentation", 
                              xmlattributes('en' as "xml:lang"), 
                              'Implemantation of ' ||item.item || '. Defined as: ' || item.definition)),
             xmlelement(name "sequence", 
                xmlelement(name "group", 
                           xmlattributes('gcdml:RegimeTimesGroup' as "ref")
                           )
             ),
           xmlelement(name attribute, 
                      xmlattributes('name' as "name",
                                    'token' as type,
                                    'required' as use))

          );
     return res;
  END;
$$;


ALTER FUNCTION gsc_db.treatment2gcdmltype(item clist_item_details) OWNER TO postgres;

--
-- TOC entry 186 (class 1259 OID 25746)
-- Name: all_item_details; Type: VIEW; Schema: gsc_db; Owner: postgres
--

CREATE VIEW all_item_details AS
    SELECT p.item, p.label, p.definition, p.expected_value, p.expected_value_details, p.value_type, p.syntax, p.example, p.help, p.occurrence, p.regexp, 'original_sample'::text AS sample_assoc FROM environmental_items p UNION SELECT mixs_checklists.item, mixs_checklists.label, mixs_checklists.definition, mixs_checklists.expected_value, mixs_checklists.expected_value_details, mixs_checklists.value_type, mixs_checklists.syntax, mixs_checklists.example, mixs_checklists.help, mixs_checklists.occurrence, mixs_checklists.regexp, mixs_checklists.sample_assoc FROM mixs_checklists;


ALTER TABLE gsc_db.all_item_details OWNER TO postgres;

--
-- TOC entry 2718 (class 0 OID 0)
-- Dependencies: 186
-- Name: VIEW all_item_details; Type: COMMENT; Schema: gsc_db; Owner: postgres
--

COMMENT ON VIEW all_item_details IS 'Contains details on every contextual data item of checklists and environmental packages.';


--
-- TOC entry 187 (class 1259 OID 25751)
-- Name: arb_silva; Type: TABLE; Schema: gsc_db; Owner: postgres; Tablespace: 
--

CREATE TABLE arb_silva (
    field_name text DEFAULT ''::text NOT NULL,
    exporter text DEFAULT ''::text NOT NULL,
    importer text DEFAULT ''::text NOT NULL,
    field_cat text DEFAULT ''::text NOT NULL,
    remark text DEFAULT ''::text NOT NULL,
    descr text DEFAULT ''::text NOT NULL,
    item text,
    silva_release integer DEFAULT 0 NOT NULL,
    CONSTRAINT im_equals_exporter CHECK (CASE WHEN ((importer = ''::text) OR (exporter = ''::text)) THEN true ELSE (importer = exporter) END)
);


ALTER TABLE gsc_db.arb_silva OWNER TO postgres;

--
-- TOC entry 2719 (class 0 OID 0)
-- Dependencies: 187
-- Name: TABLE arb_silva; Type: COMMENT; Schema: gsc_db; Owner: postgres
--

COMMENT ON TABLE arb_silva IS 'metadata around arb/silva database and im/-exporter';


--
-- TOC entry 188 (class 1259 OID 25765)
-- Name: cd_items; Type: TABLE; Schema: gsc_db; Owner: postgres; Tablespace: 
--

CREATE TABLE cd_items (
    item text NOT NULL,
    descr_short text,
    remark text,
    ctime timestamp without time zone DEFAULT now(),
    utime timestamp without time zone DEFAULT now(),
    CONSTRAINT cd_items_item_check CHECK ((item ~ '[az_]*'::text))
);


ALTER TABLE gsc_db.cd_items OWNER TO postgres;

--
-- TOC entry 2720 (class 0 OID 0)
-- Dependencies: 188
-- Name: TABLE cd_items; Type: COMMENT; Schema: gsc_db; Owner: postgres
--

COMMENT ON TABLE cd_items IS 'Contextual Data Items. This is the master table with a own defined common name for all kind of metadata items. These items should be referenced from each single metadata table for unified cross-mapping.';


--
-- TOC entry 189 (class 1259 OID 25774)
-- Name: darwin_core_mapping; Type: TABLE; Schema: gsc_db; Owner: postgres; Tablespace: 
--

CREATE TABLE darwin_core_mapping (
    item text NOT NULL,
    dcore_term text DEFAULT ''::text,
    remarks text
);


ALTER TABLE gsc_db.darwin_core_mapping OWNER TO postgres;

--
-- TOC entry 190 (class 1259 OID 25781)
-- Name: env_packages; Type: VIEW; Schema: gsc_db; Owner: postgres
--

CREATE VIEW env_packages AS
    SELECT env.label AS package_name, env.param, p.item AS strucc_name, env.requirement, p.expected_value, p.expected_value_details, p.occurrence, p.syntax, p.example, p.help AS expected_unit, CASE WHEN (env.definition = ''::text) THEN p.definition ELSE env.definition END AS definition, env.pos FROM (environmental_items p JOIN env_parameters env ON ((env.param = p.label)));


ALTER TABLE gsc_db.env_packages OWNER TO postgres;

--
-- TOC entry 191 (class 1259 OID 25786)
-- Name: environments; Type: TABLE; Schema: gsc_db; Owner: postgres; Tablespace: 
--

CREATE TABLE environments (
    label text NOT NULL,
    description text DEFAULT ''::text NOT NULL,
    utime timestamp with time zone DEFAULT now() NOT NULL,
    ctime timestamp with time zone DEFAULT now() NOT NULL,
    gcdml_name text DEFAULT ''::text
);


ALTER TABLE gsc_db.environments OWNER TO postgres;

--
-- TOC entry 2721 (class 0 OID 0)
-- Dependencies: 191
-- Name: TABLE environments; Type: COMMENT; Schema: gsc_db; Owner: postgres
--

COMMENT ON TABLE environments IS 'List of environmental packages used mainly for MIGS/MIMS/MIENS';


--
-- TOC entry 2722 (class 0 OID 0)
-- Dependencies: 191
-- Name: COLUMN environments.label; Type: COMMENT; Schema: gsc_db; Owner: postgres
--

COMMENT ON COLUMN environments.label IS 'Name of the environmental package.';


--
-- TOC entry 2723 (class 0 OID 0)
-- Dependencies: 191
-- Name: COLUMN environments.description; Type: COMMENT; Schema: gsc_db; Owner: postgres
--

COMMENT ON COLUMN environments.description IS 'some description of the rational behind this package';


--
-- TOC entry 2724 (class 0 OID 0)
-- Dependencies: 191
-- Name: COLUMN environments.utime; Type: COMMENT; Schema: gsc_db; Owner: postgres
--

COMMENT ON COLUMN environments.utime IS 'time of creation';


--
-- TOC entry 2725 (class 0 OID 0)
-- Dependencies: 191
-- Name: COLUMN environments.ctime; Type: COMMENT; Schema: gsc_db; Owner: postgres
--

COMMENT ON COLUMN environments.ctime IS 'time of creation';


--
-- TOC entry 192 (class 1259 OID 25796)
-- Name: insdc_ft_keys; Type: TABLE; Schema: gsc_db; Owner: postgres; Tablespace: 
--

CREATE TABLE insdc_ft_keys (
    item text DEFAULT ''::text NOT NULL,
    ft_key text DEFAULT ''::text NOT NULL,
    def text DEFAULT ''::text NOT NULL,
    example text DEFAULT ''::text NOT NULL,
    remark text DEFAULT ''::text NOT NULL,
    note text DEFAULT ''::text NOT NULL,
    since date DEFAULT '0001-01-01 BC'::date NOT NULL,
    deprecated date DEFAULT '0001-01-01 BC'::date NOT NULL
);


ALTER TABLE gsc_db.insdc_ft_keys OWNER TO postgres;

--
-- TOC entry 2726 (class 0 OID 0)
-- Dependencies: 192
-- Name: TABLE insdc_ft_keys; Type: COMMENT; Schema: gsc_db; Owner: postgres
--

COMMENT ON TABLE insdc_ft_keys IS 'The feature keys as specified by the INSDC http://www.insdc.org see http://www.insdc.org/files/documents/feature_table.htm';


--
-- TOC entry 193 (class 1259 OID 25810)
-- Name: insdc_qual_maps; Type: TABLE; Schema: gsc_db; Owner: postgres; Tablespace: 
--

CREATE TABLE insdc_qual_maps (
    ft_key text DEFAULT ''::text NOT NULL,
    qualifier text DEFAULT ''::text NOT NULL
);


ALTER TABLE gsc_db.insdc_qual_maps OWNER TO postgres;

--
-- TOC entry 2727 (class 0 OID 0)
-- Dependencies: 193
-- Name: TABLE insdc_qual_maps; Type: COMMENT; Schema: gsc_db; Owner: postgres
--

COMMENT ON TABLE insdc_qual_maps IS 'One to many mapping of qualifiers to feature keys';


--
-- TOC entry 194 (class 1259 OID 25818)
-- Name: insdc_qualifiers; Type: TABLE; Schema: gsc_db; Owner: postgres; Tablespace: 
--

CREATE TABLE insdc_qualifiers (
    item text DEFAULT ''::text NOT NULL,
    qualifier text DEFAULT ''::text NOT NULL,
    def text DEFAULT ''::text NOT NULL,
    format text DEFAULT ''::text NOT NULL,
    example text DEFAULT ''::text NOT NULL,
    remark text DEFAULT ''::text NOT NULL,
    note text DEFAULT ''::text NOT NULL,
    since date DEFAULT '0001-01-01 BC'::date NOT NULL,
    deprecated date DEFAULT '0001-01-01 BC'::date NOT NULL
);


ALTER TABLE gsc_db.insdc_qualifiers OWNER TO postgres;

--
-- TOC entry 2728 (class 0 OID 0)
-- Dependencies: 194
-- Name: TABLE insdc_qualifiers; Type: COMMENT; Schema: gsc_db; Owner: postgres
--

COMMENT ON TABLE insdc_qualifiers IS 'The feature key qualifiers as specified by the INSDC http://www.insdc.org see http://www.insdc.org/files/documents/feature_table.htm';


--
-- TOC entry 195 (class 1259 OID 25833)
-- Name: max_ordering; Type: TABLE; Schema: gsc_db; Owner: postgres; Tablespace: 
--

CREATE TABLE max_ordering (
    maxpos smallint DEFAULT 0,
    CONSTRAINT max_ordering_maxpos_check CHECK ((maxpos >= 0))
);


ALTER TABLE gsc_db.max_ordering OWNER TO postgres;

--
-- TOC entry 196 (class 1259 OID 25838)
-- Name: migs_checklist_choice; Type: TABLE; Schema: gsc_db; Owner: postgres; Tablespace: 
--

CREATE TABLE migs_checklist_choice (
    choice character(1) NOT NULL,
    definition text DEFAULT ''::text NOT NULL,
    ctime time without time zone DEFAULT ('now'::text)::time with time zone,
    utime time without time zone DEFAULT ('now'::text)::time with time zone
);


ALTER TABLE gsc_db.migs_checklist_choice OWNER TO postgres;

--
-- TOC entry 2729 (class 0 OID 0)
-- Dependencies: 196
-- Name: TABLE migs_checklist_choice; Type: COMMENT; Schema: gsc_db; Owner: postgres
--

COMMENT ON TABLE migs_checklist_choice IS 'Definition of the choice options for MIGS/MIMS/MIENS checklist items';


--
-- TOC entry 197 (class 1259 OID 25847)
-- Name: migs_pos; Type: TABLE; Schema: gsc_db; Owner: postgres; Tablespace: 
--

CREATE TABLE migs_pos (
    descr_name text NOT NULL,
    pos smallint,
    opos smallint,
    CONSTRAINT migs_pos_pos_check CHECK ((pos > 0)),
    CONSTRAINT migs_pos_pos_check1 CHECK ((pos >= 0))
);


ALTER TABLE gsc_db.migs_pos OWNER TO postgres;

--
-- TOC entry 2730 (class 0 OID 0)
-- Dependencies: 197
-- Name: TABLE migs_pos; Type: COMMENT; Schema: gsc_db; Owner: postgres
--

COMMENT ON TABLE migs_pos IS 'Help table to handle the automatic positioning of MIGS/MIMS/MIENS';


--
-- TOC entry 198 (class 1259 OID 25855)
-- Name: migs_versions; Type: TABLE; Schema: gsc_db; Owner: postgres; Tablespace: 
--

CREATE TABLE migs_versions (
    ver text NOT NULL,
    cdate date DEFAULT now() NOT NULL,
    pdate date DEFAULT '0001-01-01'::date NOT NULL,
    remark text DEFAULT ''::text NOT NULL,
    creator text DEFAULT "current_user"() NOT NULL
);


ALTER TABLE gsc_db.migs_versions OWNER TO postgres;

--
-- TOC entry 2731 (class 0 OID 0)
-- Dependencies: 198
-- Name: TABLE migs_versions; Type: COMMENT; Schema: gsc_db; Owner: postgres
--

COMMENT ON TABLE migs_versions IS 'Table of MIGS/MIMS/MIENS versions';


--
-- TOC entry 199 (class 1259 OID 25865)
-- Name: mixs_mandatory_items; Type: VIEW; Schema: gsc_db; Owner: postgres
--

CREATE VIEW mixs_mandatory_items AS
    SELECT mixs_checklists.label AS descr_name, mixs_checklists.definition, mixs_checklists.item, mixs_checklists.expected_value, mixs_checklists.syntax, mixs_checklists.eu, mixs_checklists.ba, mixs_checklists.pl, mixs_checklists.vi, mixs_checklists.org, mixs_checklists.me, mixs_checklists.miens_s, mixs_checklists.miens_c FROM mixs_checklists WHERE ((((((((mixs_checklists.miens_s = 'M'::bpchar) OR (mixs_checklists.eu = 'M'::bpchar)) OR (mixs_checklists.ba = 'M'::bpchar)) OR (mixs_checklists.pl = 'M'::bpchar)) OR (mixs_checklists.vi = 'M'::bpchar)) OR (mixs_checklists.org = 'M'::bpchar)) OR (mixs_checklists.me = 'M'::bpchar)) OR (mixs_checklists.miens_c = 'M'::bpchar));


ALTER TABLE gsc_db.mixs_mandatory_items OWNER TO postgres;

--
-- TOC entry 200 (class 1259 OID 25869)
-- Name: mimarks_minimal; Type: VIEW; Schema: gsc_db; Owner: postgres
--

CREATE VIEW mimarks_minimal AS
    SELECT mixs_mandatory_items.descr_name, mixs_mandatory_items.definition, mixs_mandatory_items.miens_s, mixs_mandatory_items.miens_c, mixs_mandatory_items.item, mixs_mandatory_items.expected_value, mixs_mandatory_items.syntax FROM mixs_mandatory_items WHERE ((mixs_mandatory_items.miens_s = 'M'::bpchar) OR (mixs_mandatory_items.miens_c = 'M'::bpchar));


ALTER TABLE gsc_db.mimarks_minimal OWNER TO postgres;

--
-- TOC entry 2732 (class 0 OID 0)
-- Dependencies: 200
-- Name: VIEW mimarks_minimal; Type: COMMENT; Schema: gsc_db; Owner: postgres
--

COMMENT ON VIEW mimarks_minimal IS 'Only the mandatory items of MIMARKS speciman and survey';


--
-- TOC entry 201 (class 1259 OID 25873)
-- Name: mixs_sections; Type: TABLE; Schema: gsc_db; Owner: postgres; Tablespace: 
--

CREATE TABLE mixs_sections (
    section text DEFAULT ''::text NOT NULL,
    definition text DEFAULT ''::text NOT NULL
);


ALTER TABLE gsc_db.mixs_sections OWNER TO postgres;

--
-- TOC entry 2733 (class 0 OID 0)
-- Dependencies: 201
-- Name: TABLE mixs_sections; Type: COMMENT; Schema: gsc_db; Owner: postgres
--

COMMENT ON TABLE mixs_sections IS 'Created as part of ticket#57 in MIxS trac';


--
-- TOC entry 202 (class 1259 OID 25881)
-- Name: ontologies; Type: TABLE; Schema: gsc_db; Owner: postgres; Tablespace: 
--

CREATE TABLE ontologies (
    label text NOT NULL,
    abbr text DEFAULT ''::text NOT NULL,
    url text DEFAULT ''::text NOT NULL,
    ont_ver text DEFAULT ''::text NOT NULL
);


ALTER TABLE gsc_db.ontologies OWNER TO postgres;

--
-- TOC entry 2734 (class 0 OID 0)
-- Dependencies: 202
-- Name: TABLE ontologies; Type: COMMENT; Schema: gsc_db; Owner: postgres
--

COMMENT ON TABLE ontologies IS 'Ontologies used and referenced my GSC for MIxS checklists';


--
-- TOC entry 203 (class 1259 OID 25890)
-- Name: regexps; Type: TABLE; Schema: gsc_db; Owner: postgres; Tablespace: 
--

CREATE TABLE regexps (
    exp text DEFAULT ''::text NOT NULL,
    remark text DEFAULT ''::text,
    ctime timestamp with time zone DEFAULT now(),
    utime timestamp with time zone DEFAULT now()
);


ALTER TABLE gsc_db.regexps OWNER TO postgres;

--
-- TOC entry 204 (class 1259 OID 25900)
-- Name: renaming_rules; Type: TABLE; Schema: gsc_db; Owner: postgres; Tablespace: 
--

CREATE TABLE renaming_rules (
    term text NOT NULL,
    target text
);


ALTER TABLE gsc_db.renaming_rules OWNER TO postgres;

--
-- TOC entry 205 (class 1259 OID 25906)
-- Name: sample_types; Type: TABLE; Schema: gsc_db; Owner: postgres; Tablespace: 
--

CREATE TABLE sample_types (
    label text NOT NULL,
    description text DEFAULT ''::text NOT NULL,
    gcdml_name text DEFAULT ''::text,
    utime timestamp with time zone DEFAULT now() NOT NULL,
    ctime timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT sample_types_label_check CHECK ((label ~ '[az_]*'::text))
);


ALTER TABLE gsc_db.sample_types OWNER TO postgres;

--
-- TOC entry 206 (class 1259 OID 25917)
-- Name: sequin; Type: TABLE; Schema: gsc_db; Owner: postgres; Tablespace: 
--

CREATE TABLE sequin (
    item text,
    modifier text DEFAULT ''::text NOT NULL,
    descr text DEFAULT ''::text NOT NULL
);


ALTER TABLE gsc_db.sequin OWNER TO postgres;

--
-- TOC entry 207 (class 1259 OID 25925)
-- Name: value_types; Type: TABLE; Schema: gsc_db; Owner: postgres; Tablespace: 
--

CREATE TABLE value_types (
    label text DEFAULT ''::text NOT NULL,
    descr text DEFAULT ''::text NOT NULL
);


ALTER TABLE gsc_db.value_types OWNER TO postgres;

--
-- TOC entry 2642 (class 2606 OID 25934)
-- Name: arb_silva_pkey; Type: CONSTRAINT; Schema: gsc_db; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY arb_silva
    ADD CONSTRAINT arb_silva_pkey PRIMARY KEY (field_name);


--
-- TOC entry 2645 (class 2606 OID 25936)
-- Name: contextual_data_pkey; Type: CONSTRAINT; Schema: gsc_db; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY cd_items
    ADD CONSTRAINT contextual_data_pkey PRIMARY KEY (item);


--
-- TOC entry 2635 (class 2606 OID 25938)
-- Name: env_parameters_pkey; Type: CONSTRAINT; Schema: gsc_db; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY env_parameters
    ADD CONSTRAINT env_parameters_pkey PRIMARY KEY (label, param);


--
-- TOC entry 2637 (class 2606 OID 25940)
-- Name: environmental_parameters_pkey; Type: CONSTRAINT; Schema: gsc_db; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY environmental_items
    ADD CONSTRAINT environmental_parameters_pkey PRIMARY KEY (label);


--
-- TOC entry 2647 (class 2606 OID 25942)
-- Name: environments_pkey; Type: CONSTRAINT; Schema: gsc_db; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY environments
    ADD CONSTRAINT environments_pkey PRIMARY KEY (label);


--
-- TOC entry 2649 (class 2606 OID 25944)
-- Name: insdc_ft_keys_pkey; Type: CONSTRAINT; Schema: gsc_db; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY insdc_ft_keys
    ADD CONSTRAINT insdc_ft_keys_pkey PRIMARY KEY (ft_key);


--
-- TOC entry 2651 (class 2606 OID 25946)
-- Name: insdc_qual_maps_pkey; Type: CONSTRAINT; Schema: gsc_db; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY insdc_qual_maps
    ADD CONSTRAINT insdc_qual_maps_pkey PRIMARY KEY (ft_key, qualifier);


--
-- TOC entry 2653 (class 2606 OID 25948)
-- Name: insdc_qualifiers_pkey; Type: CONSTRAINT; Schema: gsc_db; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY insdc_qualifiers
    ADD CONSTRAINT insdc_qualifiers_pkey PRIMARY KEY (qualifier);


--
-- TOC entry 2655 (class 2606 OID 25950)
-- Name: migs_checklist_choice_pkey; Type: CONSTRAINT; Schema: gsc_db; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY migs_checklist_choice
    ADD CONSTRAINT migs_checklist_choice_pkey PRIMARY KEY (choice);


--
-- TOC entry 2657 (class 2606 OID 25952)
-- Name: migs_pos_pkey; Type: CONSTRAINT; Schema: gsc_db; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY migs_pos
    ADD CONSTRAINT migs_pos_pkey PRIMARY KEY (descr_name);


--
-- TOC entry 2659 (class 2606 OID 25954)
-- Name: migs_versions_pkey; Type: CONSTRAINT; Schema: gsc_db; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY migs_versions
    ADD CONSTRAINT migs_versions_pkey PRIMARY KEY (ver);


--
-- TOC entry 2640 (class 2606 OID 25956)
-- Name: mixs_checklists_pkey; Type: CONSTRAINT; Schema: gsc_db; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY mixs_checklists
    ADD CONSTRAINT mixs_checklists_pkey PRIMARY KEY (item);


--
-- TOC entry 2661 (class 2606 OID 25958)
-- Name: mixs_sections_pkey; Type: CONSTRAINT; Schema: gsc_db; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY mixs_sections
    ADD CONSTRAINT mixs_sections_pkey PRIMARY KEY (section);


--
-- TOC entry 2663 (class 2606 OID 25960)
-- Name: ontologies_abbr_key; Type: CONSTRAINT; Schema: gsc_db; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY ontologies
    ADD CONSTRAINT ontologies_abbr_key UNIQUE (abbr);


--
-- TOC entry 2665 (class 2606 OID 25962)
-- Name: ontologies_pkey; Type: CONSTRAINT; Schema: gsc_db; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY ontologies
    ADD CONSTRAINT ontologies_pkey PRIMARY KEY (label);


--
-- TOC entry 2667 (class 2606 OID 25964)
-- Name: regexps_pkey; Type: CONSTRAINT; Schema: gsc_db; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY regexps
    ADD CONSTRAINT regexps_pkey PRIMARY KEY (exp);


--
-- TOC entry 2669 (class 2606 OID 25966)
-- Name: renaming_rules_pkey; Type: CONSTRAINT; Schema: gsc_db; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY renaming_rules
    ADD CONSTRAINT renaming_rules_pkey PRIMARY KEY (term);


--
-- TOC entry 2671 (class 2606 OID 25968)
-- Name: renaming_rules_target_key; Type: CONSTRAINT; Schema: gsc_db; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY renaming_rules
    ADD CONSTRAINT renaming_rules_target_key UNIQUE (target);


--
-- TOC entry 2673 (class 2606 OID 25970)
-- Name: sample_types_pkey; Type: CONSTRAINT; Schema: gsc_db; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY sample_types
    ADD CONSTRAINT sample_types_pkey PRIMARY KEY (label);


--
-- TOC entry 2675 (class 2606 OID 25972)
-- Name: sequin_pkey; Type: CONSTRAINT; Schema: gsc_db; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY sequin
    ADD CONSTRAINT sequin_pkey PRIMARY KEY (modifier);


--
-- TOC entry 2677 (class 2606 OID 25974)
-- Name: value_types_pkey; Type: CONSTRAINT; Schema: gsc_db; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY value_types
    ADD CONSTRAINT value_types_pkey PRIMARY KEY (label);


--
-- TOC entry 2643 (class 1259 OID 25975)
-- Name: fki_arb_cd_item_name; Type: INDEX; Schema: gsc_db; Owner: postgres; Tablespace: 
--

CREATE INDEX fki_arb_cd_item_name ON arb_silva USING btree (item);


--
-- TOC entry 2638 (class 1259 OID 25976)
-- Name: item_unique_idx; Type: INDEX; Schema: gsc_db; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX item_unique_idx ON environmental_items USING btree (item);


--
-- TOC entry 2704 (class 2620 OID 25977)
-- Name: az_cd_items_b_trg; Type: TRIGGER; Schema: gsc_db; Owner: postgres
--

CREATE TRIGGER az_cd_items_b_trg BEFORE INSERT OR UPDATE ON cd_items FOR EACH ROW EXECUTE PROCEDURE cd_items_b_trg();


--
-- TOC entry 2702 (class 2620 OID 25978)
-- Name: az_cd_items_b_trg; Type: TRIGGER; Schema: gsc_db; Owner: postgres
--

CREATE TRIGGER az_cd_items_b_trg BEFORE INSERT OR UPDATE ON environmental_items FOR EACH ROW EXECUTE PROCEDURE cd_items_b_trg();


--
-- TOC entry 2703 (class 2620 OID 25979)
-- Name: process_mixs; Type: TRIGGER; Schema: gsc_db; Owner: postgres
--

CREATE TRIGGER process_mixs BEFORE INSERT OR UPDATE ON mixs_checklists FOR EACH ROW EXECUTE PROCEDURE process_migs_change();


--
-- TOC entry 2695 (class 2606 OID 25980)
-- Name: arb_cd_item_name; Type: FK CONSTRAINT; Schema: gsc_db; Owner: postgres
--

ALTER TABLE ONLY arb_silva
    ADD CONSTRAINT arb_cd_item_name FOREIGN KEY (item) REFERENCES cd_items(item) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 2696 (class 2606 OID 25985)
-- Name: darwin_core_mapping_item_fkey; Type: FK CONSTRAINT; Schema: gsc_db; Owner: postgres
--

ALTER TABLE ONLY darwin_core_mapping
    ADD CONSTRAINT darwin_core_mapping_item_fkey FOREIGN KEY (item) REFERENCES cd_items(item) ON UPDATE CASCADE;


--
-- TOC entry 2678 (class 2606 OID 25990)
-- Name: env_parameters_label_fkey; Type: FK CONSTRAINT; Schema: gsc_db; Owner: postgres
--

ALTER TABLE ONLY env_parameters
    ADD CONSTRAINT env_parameters_label_fkey FOREIGN KEY (label) REFERENCES environments(label) ON UPDATE CASCADE;


--
-- TOC entry 2679 (class 2606 OID 25995)
-- Name: env_parameters_param_fkey; Type: FK CONSTRAINT; Schema: gsc_db; Owner: postgres
--

ALTER TABLE ONLY env_parameters
    ADD CONSTRAINT env_parameters_param_fkey FOREIGN KEY (param) REFERENCES environmental_items(label) ON UPDATE CASCADE;


--
-- TOC entry 2680 (class 2606 OID 26000)
-- Name: environmental_items_value_type_fkey; Type: FK CONSTRAINT; Schema: gsc_db; Owner: postgres
--

ALTER TABLE ONLY environmental_items
    ADD CONSTRAINT environmental_items_value_type_fkey FOREIGN KEY (value_type) REFERENCES value_types(label) ON UPDATE CASCADE DEFERRABLE;


--
-- TOC entry 2681 (class 2606 OID 26005)
-- Name: environmental_parameters_item_fkey; Type: FK CONSTRAINT; Schema: gsc_db; Owner: postgres
--

ALTER TABLE ONLY environmental_items
    ADD CONSTRAINT environmental_parameters_item_fkey FOREIGN KEY (item) REFERENCES cd_items(item) ON UPDATE CASCADE;


--
-- TOC entry 2682 (class 2606 OID 26010)
-- Name: environmental_parameters_regexp_fkey; Type: FK CONSTRAINT; Schema: gsc_db; Owner: postgres
--

ALTER TABLE ONLY environmental_items
    ADD CONSTRAINT environmental_parameters_regexp_fkey FOREIGN KEY (regexp) REFERENCES regexps(exp) ON UPDATE CASCADE ON DELETE SET DEFAULT DEFERRABLE;


--
-- TOC entry 2697 (class 2606 OID 26015)
-- Name: insdc_ft_keys_item_fkey; Type: FK CONSTRAINT; Schema: gsc_db; Owner: postgres
--

ALTER TABLE ONLY insdc_ft_keys
    ADD CONSTRAINT insdc_ft_keys_item_fkey FOREIGN KEY (item) REFERENCES cd_items(item);


--
-- TOC entry 2698 (class 2606 OID 26020)
-- Name: insdc_qual_maps_ft_key_fkey; Type: FK CONSTRAINT; Schema: gsc_db; Owner: postgres
--

ALTER TABLE ONLY insdc_qual_maps
    ADD CONSTRAINT insdc_qual_maps_ft_key_fkey FOREIGN KEY (ft_key) REFERENCES insdc_ft_keys(ft_key);


--
-- TOC entry 2699 (class 2606 OID 26025)
-- Name: insdc_qual_maps_qualifier_fkey; Type: FK CONSTRAINT; Schema: gsc_db; Owner: postgres
--

ALTER TABLE ONLY insdc_qual_maps
    ADD CONSTRAINT insdc_qual_maps_qualifier_fkey FOREIGN KEY (qualifier) REFERENCES insdc_qualifiers(qualifier);


--
-- TOC entry 2700 (class 2606 OID 26030)
-- Name: insdc_qualifiers_item_fkey; Type: FK CONSTRAINT; Schema: gsc_db; Owner: postgres
--

ALTER TABLE ONLY insdc_qualifiers
    ADD CONSTRAINT insdc_qualifiers_item_fkey FOREIGN KEY (item) REFERENCES cd_items(item);


--
-- TOC entry 2683 (class 2606 OID 26035)
-- Name: mixs_checklists_ba_fkey; Type: FK CONSTRAINT; Schema: gsc_db; Owner: postgres
--

ALTER TABLE ONLY mixs_checklists
    ADD CONSTRAINT mixs_checklists_ba_fkey FOREIGN KEY (ba) REFERENCES migs_checklist_choice(choice) ON UPDATE CASCADE;


--
-- TOC entry 2684 (class 2606 OID 26040)
-- Name: mixs_checklists_eu_fkey; Type: FK CONSTRAINT; Schema: gsc_db; Owner: postgres
--

ALTER TABLE ONLY mixs_checklists
    ADD CONSTRAINT mixs_checklists_eu_fkey FOREIGN KEY (eu) REFERENCES migs_checklist_choice(choice) ON UPDATE CASCADE;


--
-- TOC entry 2685 (class 2606 OID 26045)
-- Name: mixs_checklists_item_fkey; Type: FK CONSTRAINT; Schema: gsc_db; Owner: postgres
--

ALTER TABLE ONLY mixs_checklists
    ADD CONSTRAINT mixs_checklists_item_fkey FOREIGN KEY (item) REFERENCES cd_items(item) DEFERRABLE;


--
-- TOC entry 2686 (class 2606 OID 26050)
-- Name: mixs_checklists_me_fkey; Type: FK CONSTRAINT; Schema: gsc_db; Owner: postgres
--

ALTER TABLE ONLY mixs_checklists
    ADD CONSTRAINT mixs_checklists_me_fkey FOREIGN KEY (me) REFERENCES migs_checklist_choice(choice) ON UPDATE CASCADE;


--
-- TOC entry 2687 (class 2606 OID 26055)
-- Name: mixs_checklists_miens_c_fkey; Type: FK CONSTRAINT; Schema: gsc_db; Owner: postgres
--

ALTER TABLE ONLY mixs_checklists
    ADD CONSTRAINT mixs_checklists_miens_c_fkey FOREIGN KEY (miens_c) REFERENCES migs_checklist_choice(choice) ON UPDATE CASCADE;


--
-- TOC entry 2688 (class 2606 OID 26060)
-- Name: mixs_checklists_miens_s_fkey; Type: FK CONSTRAINT; Schema: gsc_db; Owner: postgres
--

ALTER TABLE ONLY mixs_checklists
    ADD CONSTRAINT mixs_checklists_miens_s_fkey FOREIGN KEY (miens_s) REFERENCES migs_checklist_choice(choice) ON UPDATE CASCADE;


--
-- TOC entry 2689 (class 2606 OID 26065)
-- Name: mixs_checklists_org_fkey; Type: FK CONSTRAINT; Schema: gsc_db; Owner: postgres
--

ALTER TABLE ONLY mixs_checklists
    ADD CONSTRAINT mixs_checklists_org_fkey FOREIGN KEY (org) REFERENCES migs_checklist_choice(choice) ON UPDATE CASCADE;


--
-- TOC entry 2690 (class 2606 OID 26070)
-- Name: mixs_checklists_pl_fkey; Type: FK CONSTRAINT; Schema: gsc_db; Owner: postgres
--

ALTER TABLE ONLY mixs_checklists
    ADD CONSTRAINT mixs_checklists_pl_fkey FOREIGN KEY (pl) REFERENCES migs_checklist_choice(choice) ON UPDATE CASCADE;


--
-- TOC entry 2691 (class 2606 OID 26075)
-- Name: mixs_checklists_regexp_fkey; Type: FK CONSTRAINT; Schema: gsc_db; Owner: postgres
--

ALTER TABLE ONLY mixs_checklists
    ADD CONSTRAINT mixs_checklists_regexp_fkey FOREIGN KEY (regexp) REFERENCES regexps(exp) ON UPDATE CASCADE ON DELETE SET DEFAULT DEFERRABLE;


--
-- TOC entry 2692 (class 2606 OID 26080)
-- Name: mixs_checklists_sample_assoc_fkey; Type: FK CONSTRAINT; Schema: gsc_db; Owner: postgres
--

ALTER TABLE ONLY mixs_checklists
    ADD CONSTRAINT mixs_checklists_sample_assoc_fkey FOREIGN KEY (sample_assoc) REFERENCES sample_types(label);


--
-- TOC entry 2693 (class 2606 OID 26085)
-- Name: mixs_checklists_value_type_fkey; Type: FK CONSTRAINT; Schema: gsc_db; Owner: postgres
--

ALTER TABLE ONLY mixs_checklists
    ADD CONSTRAINT mixs_checklists_value_type_fkey FOREIGN KEY (value_type) REFERENCES value_types(label) ON UPDATE CASCADE DEFERRABLE;


--
-- TOC entry 2694 (class 2606 OID 26090)
-- Name: mixs_checklists_vi_fkey; Type: FK CONSTRAINT; Schema: gsc_db; Owner: postgres
--

ALTER TABLE ONLY mixs_checklists
    ADD CONSTRAINT mixs_checklists_vi_fkey FOREIGN KEY (vi) REFERENCES migs_checklist_choice(choice) ON UPDATE CASCADE;


--
-- TOC entry 2701 (class 2606 OID 26095)
-- Name: sequin_item_fkey; Type: FK CONSTRAINT; Schema: gsc_db; Owner: postgres
--

ALTER TABLE ONLY sequin
    ADD CONSTRAINT sequin_item_fkey FOREIGN KEY (item) REFERENCES cd_items(item);


-- Completed on 2016-02-22 09:58:57 CET

--
-- PostgreSQL database dump complete
--

