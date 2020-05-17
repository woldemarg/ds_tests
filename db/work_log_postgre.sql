--
-- PostgreSQL database dump
--

-- Dumped from database version 11.5 (Debian 11.5-1.pgdg90+1)
-- Dumped by pg_dump version 11.5 (Debian 11.5-1.pgdg90+1)

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

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: dailylog; Type: TABLE; Schema: public; Owner: user
--

CREATE TABLE public.dailylog (
    id integer NOT NULL,
    date date NOT NULL,
    spent_time time without time zone NOT NULL,
    task_name character varying(100) NOT NULL,
    task_comment character varying(200) NOT NULL,
    deleted_at timestamp with time zone,
    project_id integer,
    work_type_id integer NOT NULL,
    worker_id integer NOT NULL
);


ALTER TABLE public.dailylog OWNER TO "user";

--
-- Name: dailylog_id_seq; Type: SEQUENCE; Schema: public; Owner: user
--

CREATE SEQUENCE public.dailylog_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.dailylog_id_seq OWNER TO "user";

--
-- Name: dailylog_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: user
--

ALTER SEQUENCE public.dailylog_id_seq OWNED BY public.dailylog.id;


--
-- Name: dailyplan; Type: TABLE; Schema: public; Owner: user
--

CREATE TABLE public.dailyplan (
    id integer NOT NULL,
    date date NOT NULL,
    estimated_time time without time zone NOT NULL,
    deleted_at timestamp with time zone,
    project_id integer NOT NULL,
    vacancy_id integer NOT NULL,
    worker_id integer NOT NULL
);


ALTER TABLE public.dailyplan OWNER TO "user";

--
-- Name: dailyplan_id_seq; Type: SEQUENCE; Schema: public; Owner: user
--

CREATE SEQUENCE public.dailyplan_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.dailyplan_id_seq OWNER TO "user";

--
-- Name: dailyplan_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: user
--

ALTER SEQUENCE public.dailyplan_id_seq OWNED BY public.dailyplan.id;


--
-- Name: project; Type: TABLE; Schema: public; Owner: user
--

CREATE TABLE public.project (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.project OWNER TO "user";

--
-- Name: project_id_seq; Type: SEQUENCE; Schema: public; Owner: user
--

CREATE SEQUENCE public.project_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.project_id_seq OWNER TO "user";

--
-- Name: project_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: user
--

ALTER SEQUENCE public.project_id_seq OWNED BY public.project.id;


--
-- Name: projectworker; Type: TABLE; Schema: public; Owner: user
--

CREATE TABLE public.projectworker (
    id integer NOT NULL,
    start_date date NOT NULL,
    end_date date NOT NULL,
    is_parttime boolean NOT NULL,
    deleted_at timestamp with time zone,
    project_id integer NOT NULL,
    vacancy_on_project_id integer NOT NULL,
    worker_id integer NOT NULL
);


ALTER TABLE public.projectworker OWNER TO "user";

--
-- Name: projectworker_id_seq; Type: SEQUENCE; Schema: public; Owner: user
--

CREATE SEQUENCE public.projectworker_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.projectworker_id_seq OWNER TO "user";

--
-- Name: projectworker_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: user
--

ALTER SEQUENCE public.projectworker_id_seq OWNED BY public.projectworker.id;


--
-- Name: vacancy; Type: TABLE; Schema: public; Owner: user
--

CREATE TABLE public.vacancy (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.vacancy OWNER TO "user";

--
-- Name: vacancy_id_seq; Type: SEQUENCE; Schema: public; Owner: user
--

CREATE SEQUENCE public.vacancy_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.vacancy_id_seq OWNER TO "user";

--
-- Name: vacancy_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: user
--

ALTER SEQUENCE public.vacancy_id_seq OWNED BY public.vacancy.id;


--
-- Name: worker; Type: TABLE; Schema: public; Owner: user
--

CREATE TABLE public.worker (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.worker OWNER TO "user";

--
-- Name: worker_id_seq; Type: SEQUENCE; Schema: public; Owner: user
--

CREATE SEQUENCE public.worker_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.worker_id_seq OWNER TO "user";

--
-- Name: worker_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: user
--

ALTER SEQUENCE public.worker_id_seq OWNED BY public.worker.id;


--
-- Name: worktype; Type: TABLE; Schema: public; Owner: user
--

CREATE TABLE public.worktype (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.worktype OWNER TO "user";

--
-- Name: worktype_id_seq; Type: SEQUENCE; Schema: public; Owner: user
--

CREATE SEQUENCE public.worktype_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.worktype_id_seq OWNER TO "user";

--
-- Name: worktype_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: user
--

ALTER SEQUENCE public.worktype_id_seq OWNED BY public.worktype.id;


--
-- Name: dailylog id; Type: DEFAULT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.dailylog ALTER COLUMN id SET DEFAULT nextval('public.dailylog_id_seq'::regclass);


--
-- Name: dailyplan id; Type: DEFAULT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.dailyplan ALTER COLUMN id SET DEFAULT nextval('public.dailyplan_id_seq'::regclass);


--
-- Name: project id; Type: DEFAULT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.project ALTER COLUMN id SET DEFAULT nextval('public.project_id_seq'::regclass);


--
-- Name: projectworker id; Type: DEFAULT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.projectworker ALTER COLUMN id SET DEFAULT nextval('public.projectworker_id_seq'::regclass);


--
-- Name: vacancy id; Type: DEFAULT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.vacancy ALTER COLUMN id SET DEFAULT nextval('public.vacancy_id_seq'::regclass);


--
-- Name: worker id; Type: DEFAULT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.worker ALTER COLUMN id SET DEFAULT nextval('public.worker_id_seq'::regclass);


--
-- Name: worktype id; Type: DEFAULT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.worktype ALTER COLUMN id SET DEFAULT nextval('public.worktype_id_seq'::regclass);


--
-- Data for Name: dailylog; Type: TABLE DATA; Schema: public; Owner: user
--

COPY public.dailylog (id, date, spent_time, task_name, task_comment, deleted_at, project_id, work_type_id, worker_id) FROM stdin;
1	2020-01-29	04:00:00	Help on presales project	Environmental role hold book. Type employee without wear sister he staff size. All red win leg before would.	\N	\N	3	4
2	2020-01-30	04:00:00	IPR	Book situation paper old day from. Science boy professional draw.\nHistory service much camera. Might ball them similar.	\N	\N	1	4
3	2020-01-31	04:00:00	IPR	Me understand seven claim.	\N	\N	1	4
4	2020-02-01	03:00:00	IPR	Understand when tonight artist. Institution sign star moment them if tough trade. Couple hospital whose along hit inside end.	\N	\N	1	4
5	2020-02-02	03:00:00	IPR	Whatever ever ball computer popular past possible. Brother decade bill time. None whom fill not least.	\N	\N	1	4
6	2020-02-03	07:00:00	Task-1035	Onto respond follow practice drive themselves play program. Rest summer leg.	\N	5	2	4
7	2020-02-04	04:00:00	IPR	Effort they accept sure consider wide his. Fire condition then civil look tough character.\nWhom bar guess night southern. Senior song open top bed.	\N	\N	1	4
8	2020-02-05	06:00:00	Task-2240	Throw development situation high call market. Story drug attack property act student wonder. Wear foreign behavior we outside.	\N	5	2	4
9	2020-02-06	05:00:00	IPR	Group kitchen raise national huge fish.\nPurpose sound against community occur. Quality meet think may should new set.	\N	\N	1	4
10	2020-02-07	03:00:00	IPR	Discuss station once open land stand mission. Song certainly just PM perform season language. Value will still face least pretty.	\N	\N	1	4
11	2020-02-08	02:00:00	Help on presales project	Person region before project again. Wall foreign edge list week statement kind table.	\N	\N	3	4
12	2020-02-09	08:00:00	Task-1229	Ever operation special tonight technology size ten oil. Yes home image debate majority money.	\N	5	2	4
13	2020-02-10	05:00:00	Help on presales project	Home central across seem how issue. Pm provide study question thus.	\N	\N	3	4
14	2020-02-11	08:00:00	Task-2847	Star nature science book attorney. Hit magazine require particular opportunity how answer. Into religious pay recognize first arrive.	\N	5	2	4
15	2020-02-12	07:00:00	Task-2168	Use forward lose several work. Response begin bad those.\nDevelop agreement whole decide rich.\nName yourself religious great wall car word.	\N	5	2	4
16	2020-02-13	02:00:00	Help on presales project	Through next deal oil have bank. Should offer detail difference exactly. Half happen expect child.	\N	\N	3	4
17	2020-02-14	08:00:00	Task-3194	Ahead be price condition public speak make.\nCollege hope whose be probably staff marriage week. Discussion could hold worry accept live among.	\N	5	2	4
18	2020-02-15	05:00:00	Help on presales project	Father star support skill. Speak edge relationship simple avoid effect growth answer.	\N	\N	3	4
19	2020-02-16	05:00:00	Help on presales project	Impact top person we risk owner. Send indicate attack house somebody coach everybody. Series off debate early this moment rather whole.	\N	\N	3	4
20	2020-02-18	03:00:00	Help on presales project	Magazine attack heart every. Arm actually oil natural clearly. Scene defense break help.	\N	\N	3	4
21	2020-02-20	02:00:00	IPR	Still approach detail number office. Project media head born especially couple red issue.	\N	\N	1	4
22	2020-02-21	04:00:00	IPR	Prevent hot television if cover watch economy. Risk population star myself professor assume other door.	\N	\N	1	4
23	2020-02-24	05:00:00	Help on presales project	Tend material safe card present even. Still common sometimes phone. Book through home two attention.	\N	\N	3	4
24	2020-02-25	03:00:00	IPR	Simple already major and PM probably. Maintain consumer decade already it west.	\N	\N	1	4
25	2020-02-26	03:00:00	IPR	End speak write. Work behind kitchen seek can meeting lay among.\nRole sell have mind dark. Course actually would human for each agree.	\N	\N	1	4
26	2020-02-28	02:00:00	Help on presales project	Box service administration take thought land. Son area though better top. Effort hard best nice.	\N	\N	3	4
27	2020-02-29	05:00:00	Help on presales project	Nice international political life range require. Wrong thousand important walk across check.	\N	\N	3	4
28	2020-03-02	05:00:00	IPR	Degree through understand year common wall affect. Fight word blood strong stock. Let carry he moment impact must office.	\N	\N	1	4
29	2020-03-03	05:00:00	Help on presales project	Choice whose space next lose. Movie well capital quality. General concern study kitchen rather say husband.	\N	\N	3	4
30	2020-01-30	05:00:00	IPR	Bad pretty town put remember security walk. Team national news use make either bed.	\N	\N	1	5
31	2020-01-31	06:00:00	Task-4249	Discover employee attention college. Tv already indicate since.	\N	1	2	5
32	2020-02-01	07:00:00	Task-1801	We should senior station along. Exactly also good wind. Long art run sea. Send soldier together article treatment blue.	\N	1	2	5
33	2020-02-02	06:00:00	Task-3900	Identify raise police certainly forget eat. Too purpose son cell.	\N	1	2	5
34	2020-02-03	06:00:00	Task-3602	Beat fire player something process body its. Direction left recent rich. His study important key sometimes.	\N	1	2	5
35	2020-02-04	05:00:00	Help on presales project	Game fear bad decision indicate bar style indicate. History present yes move.	\N	\N	3	5
36	2020-02-05	05:00:00	Help on presales project	Ability tonight consider marriage. Writer enjoy case body.\nCreate true one say out. Audience else sign whether.	\N	\N	3	5
37	2020-02-06	02:00:00	Help on presales project	Develop work growth author suddenly brother. Speak cause down hope field husband put religious.	\N	\N	3	5
38	2020-02-07	05:00:00	IPR	Like expect bag. Clearly practice room thus hit type option.\nTax between meet evidence history share husband development.	\N	\N	1	5
39	2020-02-08	08:00:00	Task-4679	Unit mention upon art establish into hold. Wrong market ball evidence religious score season.	\N	1	2	5
40	2020-02-09	02:00:00	Help on presales project	Suggest by sister full move. Thought military green country cover shoulder center.	\N	\N	3	5
41	2020-02-10	03:00:00	Help on presales project	However even discover. Store property to future specific.	\N	\N	3	5
42	2020-02-11	02:00:00	IPR	Table teach network. Like song everybody reality seat dinner detail.	\N	\N	1	5
43	2020-02-12	05:00:00	IPR	Plant chance effort usually research represent sure. Mind none note either. Air management church simply.	\N	\N	1	5
44	2020-02-13	07:00:00	Task-3232	True visit find base threat actually. Weight church tell be college situation. Data room above.\nAttention where nation ten interest size.	\N	1	2	5
45	2020-02-14	07:00:00	Task-3301	Cover east mother year charge understand. Capital sometimes over enjoy blood. Loss mean board institution act pretty notice leader.	\N	1	2	5
46	2020-02-15	05:00:00	Help on presales project	Create close across since ground charge present. Investment war I do work whole.	\N	\N	3	5
47	2020-02-16	04:00:00	IPR	Move late wind defense design minute recognize. Keep particular bad town.\nMonth speech hit capital enjoy wife feeling.	\N	\N	1	5
48	2020-02-17	07:00:00	Task-1247	Debate star without identify. Single fight since teach tax. Coach establish wall these north wait sit.	\N	4	2	5
49	2020-02-18	05:00:00	Help on presales project	Usually partner interview suffer. Day series education.\nHair research guy like follow find event. Charge see sign spend wind voice somebody.	\N	\N	3	5
50	2020-02-19	03:00:00	IPR	Own often magazine focus condition benefit allow consider. Beautiful miss follow expert summer remember. Travel skin society.	\N	\N	1	5
51	2020-02-20	03:00:00	Help on presales project	See power sit already anyone. Wind appear success only space likely. Goal quickly green continue.	\N	\N	3	5
52	2020-02-21	03:00:00	IPR	Best anything pass help professor fine whether strategy. Leader note meeting family. Generation west foot.	\N	\N	1	5
53	2020-02-22	05:00:00	IPR	Reality push hear language. Son stage medical thing town whom question.	\N	\N	1	5
54	2020-02-23	05:00:00	Help on presales project	Suggest technology work reach prove. Raise bill anything on per concern seek.\nCost his individual suddenly. Bill break office generation more book.	\N	\N	3	5
55	2020-02-24	03:00:00	Help on presales project	Spring treat official structure thought exactly environmental mean. Quickly spend last together long art different.	\N	\N	3	5
56	2020-02-25	02:00:00	Help on presales project	Laugh rise choice here. Grow truth name.	\N	\N	3	5
57	2020-02-26	05:00:00	IPR	To learn phone amount. Campaign thought near artist provide eight every. Individual discussion allow security these.	\N	\N	1	5
58	2020-02-27	04:00:00	Help on presales project	Consumer maybe front risk deal same. Court moment operation entire everybody skill. Head institution around far town.	\N	\N	3	5
59	2020-02-28	06:00:00	Task-2490	Issue drug blood process.	\N	4	2	5
60	2020-02-29	06:00:00	Task-3044	Modern necessary police just government can last. Well subject generation movement really prepare him safe.	\N	4	2	5
61	2020-03-01	03:00:00	Help on presales project	Or nation today goal cost deep trial. Guy even movement everything action traditional. Your under decision because raise energy.	\N	\N	3	5
62	2020-03-02	04:00:00	IPR	Indeed back stock table happy hope. Travel international century thousand about. Time store black.\nHe morning almost each quickly effect must.	\N	\N	1	5
63	2020-03-03	04:00:00	IPR	Year serve whose push bring should. Listen fish mention. Arrive he role soldier kid determine.\nBit spring risk. Season wrong rather himself will Mrs.	\N	\N	1	5
64	2020-01-30	03:00:00	Help on presales project	Everything measure history air.\nAdmit dream capital leave response thousand yes.	\N	\N	3	6
65	2020-01-31	02:00:00	Help on presales project	People himself need indicate push why.	\N	\N	3	6
66	2020-02-01	02:00:00	Help on presales project	How join human man fact draw hit experience. Team picture final outside scene it weight.	\N	\N	3	6
67	2020-02-02	05:00:00	IPR	Technology family report executive mind subject. Foreign challenge position direction nor never.	\N	\N	1	6
68	2020-02-03	05:00:00	IPR	Marriage leave brother site section. Fund sort force door old. In painting debate woman.	\N	\N	1	6
69	2020-02-04	05:00:00	Help on presales project	Learn red social letter professor. Whole already fund. My data laugh bag.	\N	\N	3	6
70	2020-02-05	02:00:00	IPR	Everybody standard back whether. Spend television leader many all final. Change environmental government who open. Suddenly training site student.	\N	\N	1	6
71	2020-02-06	05:00:00	IPR	Administration federal debate pull. Center job book report trouble chance.	\N	\N	1	6
72	2020-02-07	04:00:00	IPR	Break expert figure suggest whatever interest.\nEnter participant maintain provide who people order note.	\N	\N	1	6
73	2020-02-08	05:00:00	IPR	Hope attack tax whole establish in put wind. Happen conference hard mean keep stop stock. House machine heavy protect field.	\N	\N	1	6
74	2020-02-09	03:00:00	Help on presales project	Seek teach assume else professional. Increase community open to.\nMillion staff put industry adult. Quite they might occur ahead election.	\N	\N	3	6
75	2020-02-10	02:00:00	IPR	Eye federal senior since. Heart government heavy property magazine tree parent.	\N	\N	1	6
76	2020-02-11	03:00:00	Help on presales project	Ball role really three. Others evidence foot again church upon use. Enjoy find old still per. Decide speech unit responsibility mean white.	\N	\N	3	6
77	2020-02-12	04:00:00	IPR	Involve sense think individual some. Especially provide Congress democratic us paper realize war.	\N	\N	1	6
78	2020-02-14	04:00:00	IPR	Do church get today behavior term mean. Must produce gas feel word.\nThank series stuff race thousand federal accept. Would rest with stand.	\N	\N	1	6
79	2020-02-15	03:00:00	IPR	Toward note house arrive back game win. Establish industry day bank. Treatment might drug behavior imagine. Year woman late social bring.	\N	\N	1	6
80	2020-02-16	03:00:00	Help on presales project	Hold energy president thousand. Hold success bad order page. We improve per finally.	\N	\N	3	6
81	2020-02-17	03:00:00	Help on presales project	Oil even bank floor radio. Defense itself market fire. Your fine nice easy five only professor crime. Reality ground practice.	\N	\N	3	6
82	2020-02-18	04:00:00	IPR	Especially fill camera eye medical agreement only thus. Cover account must win.	\N	\N	1	6
83	2020-02-21	02:00:00	IPR	Thank close interesting watch rule visit medical.	\N	\N	1	6
84	2020-02-24	02:00:00	IPR	It interest continue per hospital whom. Statement represent life across.	\N	\N	1	6
85	2020-02-26	03:00:00	IPR	None time natural since. Little left woman type.\nLarge prove recently party face. Establish early more animal spring training.	\N	\N	1	6
86	2020-02-27	05:00:00	Help on presales project	Happen recognize prepare. Both some strong. Nor tell budget theory will.	\N	\N	3	6
87	2020-03-01	03:00:00	Help on presales project	Member the business stage. Which north education land focus head factor.	\N	\N	3	6
88	2020-03-02	02:00:00	Help on presales project	Door industry air bed across go. Care light begin dog sort ok story continue. Role arm skin teacher prepare reveal build over. Pretty current easy.	\N	\N	3	6
89	2020-01-29	02:00:00	Help on presales project	Reveal business assume standard final increase. Resource debate lawyer now. Analysis lead main who bar.	\N	\N	3	7
179	2020-02-20	04:00:00	Test task-3224	Little develop care agent mother.	\N	1	2	9
90	2020-01-30	02:00:00	Help on presales project	Former movement dinner history. Candidate many side reflect color.\nBank speak else main religious sit. Heavy join management everyone.	\N	\N	3	7
91	2020-01-31	04:00:00	IPR	Offer mind former outside cut. Free PM glass indeed. Phone product everybody just teacher entire around sort.	\N	\N	1	7
92	2020-02-01	02:00:00	Help on presales project	Rise company central avoid over practice. When section quality term trouble.\nWear visit southern above.	\N	\N	3	7
93	2020-02-02	08:00:00	Task-2961	Community building police worker again kid. Really cold four. Soon whether dog grow.\nTravel bed any. Course beautiful later nearly real.	\N	3	2	7
94	2020-02-03	04:00:00	Help on presales project	North hot instead should voice the cut. Use bit campaign price. Land know interest push capital explain practice.	\N	\N	3	7
95	2020-02-04	03:00:00	IPR	Care low product leave blue shake.\nFinally one help middle. Near past project rise teacher. Read budget expert.	\N	\N	1	7
96	2020-02-05	04:00:00	Help on presales project	Head we recognize despite. Determine role why so leg goal message.\nFund present those factor black.	\N	\N	3	7
97	2020-02-06	04:00:00	IPR	Future card nothing eye wrong dinner. Benefit new floor child far. Show message along high what special which.	\N	\N	1	7
98	2020-02-07	02:00:00	Help on presales project	Tend would unit new. Education eight letter sit determine close resource.	\N	\N	3	7
99	2020-02-08	06:00:00	Task-2762	Building successful deal particularly.\nFloor civil often ready out. Sort meeting perform along take pretty fight seek. Step popular pull investment.	\N	3	2	7
100	2020-02-09	08:00:00	Task-1341	Daughter challenge too wall opportunity blue. Spring ever focus country.\nWoman west follow newspaper. Group party soldier memory cost.	\N	3	2	7
101	2020-02-10	08:00:00	Task-1240	Involve door boy argue wrong Mr sell. Property book culture film. Stuff leg check cause.\nShe detail factor. Which become computer hour.	\N	3	2	7
102	2020-02-11	04:00:00	IPR	Despite remain space which source service. Probably way everyone heart campaign law again. Have southern teacher successful campaign.	\N	\N	1	7
103	2020-02-12	02:00:00	Help on presales project	Significant reach marriage Democrat. Career from experience team. Store animal half pick.	\N	\N	3	7
104	2020-02-13	06:00:00	Task-4414	Art authority wish cost also myself.\nPlant son say learn network. Structure beautiful cold short election evening team market.	\N	3	2	7
105	2020-02-14	05:00:00	IPR	Establish factor economy now before throw. Discover continue order team respond production manager. Blood strong despite religious.	\N	\N	1	7
106	2020-02-15	03:00:00	Help on presales project	Room score human marriage. Rock share imagine while actually protect low. Individual this space voice my machine read.	\N	\N	3	7
107	2020-02-16	05:00:00	Help on presales project	Happen say report coach citizen nor yard. Single share charge on energy. Do edge after campaign cup argue.	\N	\N	3	7
108	2020-02-17	05:00:00	Help on presales project	Indeed field both lose marriage worry. Again degree sure speak go. Behavior short sell study than him.	\N	\N	3	7
109	2020-02-18	02:00:00	IPR	Movie free expect question area high.\nHome girl current check possible. Agree purpose test federal fill. Seat over accept major picture.	\N	\N	1	7
110	2020-02-19	03:00:00	Help on presales project	Himself situation scene change prevent figure if.\nWork age bring road consumer. Blue guy beyond maybe firm begin. Kind on spend laugh dog use.	\N	\N	3	7
111	2020-02-20	06:00:00	Task-3692	Coach build section at. American offer kitchen. Only region writer become base performance answer.\nHour field even turn. Under talk realize inside.	\N	2	2	7
112	2020-02-21	07:00:00	Task-3151	Mouth wind job. Live benefit hear risk.	\N	2	2	7
113	2020-02-22	02:00:00	Help on presales project	Project actually how magazine skin safe nation. Difference pressure challenge western sometimes dream brother. Production owner within oil trouble.	\N	\N	3	7
114	2020-02-23	07:00:00	Task-4811	Seven three speak right. Guy person score sport eye sing. President thought debate box. Shake picture news responsibility range couple would garden.	\N	2	2	7
115	2020-02-24	02:00:00	IPR	Many production forget central picture style admit. Realize side senior loss interesting sort.	\N	\N	1	7
116	2020-02-25	07:00:00	Task-2491	Instead reason white quite.\nSurface serve strong. Cause cut Mrs concern nice baby. Pattern father treat.	\N	2	2	7
117	2020-02-26	08:00:00	Task-4400	Finish source religious office writer star. Environment born instead clearly.	\N	2	2	7
118	2020-02-27	03:00:00	IPR	Professional brother care manage want another world. Discussion maintain cup however later ball bed.	\N	\N	1	7
119	2020-02-28	03:00:00	IPR	Leader event enjoy garden often question office. Order worker area there either. Score available chair model five picture.	\N	\N	1	7
120	2020-02-29	08:00:00	Task-4202	One protect this career image. Read above example church ten newspaper. Foreign determine nature attorney.	\N	2	2	7
121	2020-03-01	08:00:00	Task-4573	Rest natural often. Seven director yourself pass political also. Finish never instead.\nOffer reduce still up. Stop public necessary hair their.	\N	2	2	7
122	2020-03-02	04:00:00	Help on presales project	Radio change part hospital. Star with sing doctor draw already.	\N	\N	3	7
123	2020-03-03	07:00:00	Task-2810	Someone ten during their whether. Think drug than consider. Baby environment agree walk big husband medical catch.	\N	2	2	7
124	2020-01-30	04:00:00	Help on presales project	Take black building yet challenge. Thank color guy movie third purpose.	\N	\N	3	8
125	2020-01-31	04:00:00	Help on presales project	Film campaign middle. Cultural writer law activity better. Fact respond almost idea again else.	\N	\N	3	8
126	2020-02-01	04:00:00	Help on presales project	Effort product or early cell reflect assume. Never night so rather process. Computer such action kid six move than.	\N	\N	3	8
127	2020-02-02	02:00:00	Help on presales project	Turn with stay these special after. Book term sit. Indicate east onto often clearly gas fine.\nSide school shake though certain.	\N	\N	3	8
128	2020-02-03	04:00:00	IPR	Career recent field marriage structure age nation policy. Only real reason lawyer drive off service. Court on modern include the bar suddenly.	\N	\N	1	8
129	2020-02-04	07:00:00	Task-2502	Feeling strategy them nothing. Especially receive fish hear marriage.	\N	2	2	8
130	2020-02-05	03:00:00	IPR	Turn collection throw white without firm. Take tell western let between none suddenly.	\N	\N	1	8
178	2020-02-19	02:00:00	Test task-1215	Opportunity painting marriage room news as. Make value quality plant. Compare discover return hour.	\N	1	2	9
131	2020-02-06	04:00:00	Help on presales project	Learn effort school its shoulder. Front main civil yeah evening speak idea. Evidence through blood wonder commercial approach threat.	\N	\N	3	8
132	2020-02-07	06:00:00	Task-1537	Husband away pay in around choice. Reach general huge deep difficult. Card describe claim image sea.	\N	2	2	8
133	2020-02-08	02:00:00	IPR	Both hit beautiful market. Compare quite answer bar.	\N	\N	1	8
134	2020-02-09	02:00:00	Help on presales project	Environment must son nice deal choose. Wonder real order knowledge cut. Player let sister your general activity rather discover.	\N	\N	3	8
135	2020-02-10	02:00:00	IPR	Fight way save house partner report little.	\N	\N	1	8
136	2020-02-11	03:00:00	Help on presales project	Arrive it raise idea technology teacher.	\N	\N	3	8
137	2020-02-12	03:00:00	IPR	Bar again organization exactly forget fly likely. Far street leader man finish.	\N	\N	1	8
138	2020-02-13	06:00:00	Task-3510	Staff wonder sit democratic relate stay. Word method research pay. Exactly foot simply. City some concern condition.	\N	2	2	8
139	2020-02-14	07:00:00	Task-4180	Impact difference manage account fill. Weight cover product suggest fast.	\N	2	2	8
140	2020-02-15	05:00:00	Help on presales project	Face guess believe network possible. Authority reason purpose benefit positive former yeah.	\N	\N	3	8
141	2020-02-16	07:00:00	Task-1648	Professor major step force today such between. Child several idea bring business budget.	\N	1	2	8
142	2020-02-17	05:00:00	Help on presales project	Early seat from life support sign ahead. Listen page return tough serve. Back tree never wonder whatever necessary.	\N	\N	3	8
143	2020-02-18	06:00:00	Task-3095	Present indicate head figure. Wind floor the. Understand risk situation.\nFew if scientist thing. Far with very him military house direction.	\N	1	2	8
144	2020-02-19	05:00:00	Help on presales project	Need third recognize degree several action institution. Also treatment pick foot until.	\N	\N	3	8
145	2020-02-20	03:00:00	Help on presales project	Why arrive practice energy leader pretty. Themselves party trade half. Major ground cost make blood think.	\N	\N	3	8
146	2020-02-21	03:00:00	Help on presales project	Hotel yet picture example throughout himself. Plan agency true.	\N	\N	3	8
147	2020-02-22	05:00:00	IPR	West range color wonder.\nFrom lead approach partner. Option year such that happy present matter able.\nThousand over light scene.	\N	\N	1	8
148	2020-02-23	08:00:00	Task-1745	Protect game if democratic. Message change account administration arrive wall maybe.	\N	1	2	8
149	2020-02-24	02:00:00	Help on presales project	Leg region environmental. Almost west area list notice.\nYear imagine across. Beat cover something gun game.	\N	\N	3	8
150	2020-02-25	05:00:00	Help on presales project	Paper trouble run company listen product. Speak stock which movie.	\N	\N	3	8
151	2020-02-26	04:00:00	Help on presales project	Meet ahead pressure. Hospital realize baby indicate sell reveal recognize tend.	\N	\N	3	8
152	2020-02-27	08:00:00	Task-4362	Operation eye involve father suffer operation usually. Sign security necessary will citizen begin economy. Black exactly left return.	\N	1	2	8
153	2020-02-28	07:00:00	Task-3446	Whether house trial push. Rate suffer rule successful rather thus worker.\nUs generation week wall measure. Why number common.	\N	1	2	8
154	2020-02-29	03:00:00	Help on presales project	Include page dark nature walk six morning. Bill pretty long pretty. Seek collection dinner force second.	\N	\N	3	8
155	2020-03-01	05:00:00	IPR	Determine education computer effect. Painting seat star think hour different such. Relationship design look final out science stuff.	\N	\N	1	8
156	2020-03-02	05:00:00	IPR	Hit example their hold speech something. Political particular voice western happy. Miss business sense sound action threat value same.	\N	\N	1	8
157	2020-03-03	06:00:00	Task-1500	Order situation again. Ten control where general.	\N	1	2	8
158	2020-01-30	02:00:00	Test task-3085	Guess interesting modern agent name floor. Particularly doctor after. But security walk simple figure policy woman.	\N	1	2	9
159	2020-01-31	05:00:00	IPR	Customer offer worry bank until Mr. Exactly fine ten different.	\N	\N	1	9
160	2020-02-01	03:00:00	Test task-2413	Reflect voice threat me attack also provide. Realize door know particularly argue certain call. Professional address amount often sound likely after.	\N	1	2	9
161	2020-02-02	02:00:00	Test task-2424	Affect clear possible view serve answer ask. Head in score clearly plan. He wide local trial.	\N	1	2	9
162	2020-02-03	02:00:00	Test task-1007	Try east Mrs ago create. If night last provide decade. Field drop road might.	\N	1	2	9
163	2020-02-04	02:00:00	IPR	Next understand public consumer firm hear. Door watch hard responsibility never require than.	\N	\N	1	9
164	2020-02-05	03:00:00	IPR	Improve call successful add. Which area government bill low. Owner into thought.	\N	\N	1	9
165	2020-02-06	05:00:00	IPR	Soon today artist deep within measure different. Power appear traditional need.	\N	\N	1	9
166	2020-02-07	02:00:00	Test task-3167	Eye parent assume often. Record day bar real also in model skill.	\N	1	2	9
167	2020-02-08	04:00:00	Test task-3404	War pretty road yourself. After note fact fund.	\N	1	2	9
168	2020-02-09	02:00:00	IPR	Reduce against present yes. Economy sort much movie already executive fight.\nForm something third hotel.	\N	\N	1	9
169	2020-02-10	05:00:00	IPR	Simple whose hot sense reach suffer. Forward but item increase.	\N	\N	1	9
170	2020-02-11	02:00:00	Test task-4610	Tv outside happen. Often either mention during wind news item.	\N	1	2	9
171	2020-02-12	02:00:00	Test task-2125	Ground produce power more TV prevent others moment. Cultural ahead car product parent.\nProject bill five sell everything.	\N	1	2	9
172	2020-02-13	05:00:00	IPR	Add space purpose recent address president. Writer kitchen camera within successful.	\N	\N	1	9
173	2020-02-14	03:00:00	Test task-1172	Put trade teach scene. When health receive yourself shake garden personal.	\N	1	2	9
174	2020-02-15	03:00:00	IPR	Certainly seven treat. Consider on likely rather total war clear.\nNotice economic necessary room by. Them time thing movie. Address area wait relate.	\N	\N	1	9
175	2020-02-16	04:00:00	IPR	Back star machine management young push. Manage identify stock finally. Offer car know pattern.	\N	\N	1	9
176	2020-02-17	02:00:00	Test task-4802	Budget eight government admit. Case one southern official agreement adult fear kitchen.	\N	1	2	9
177	2020-02-18	02:00:00	Test task-1202	Southern customer and relationship. Own back practice big.	\N	1	2	9
180	2020-02-21	03:00:00	Test task-3381	Cell figure their team.	\N	1	2	9
181	2020-02-22	04:00:00	IPR	Early they performance kitchen determine recently. As position hot long dark serious beautiful. White body work black.	\N	\N	1	9
182	2020-02-23	05:00:00	IPR	Specific light really information. Worker experience special spend form with during. Return race unit most on although.\nFormer low live realize.	\N	\N	1	9
183	2020-02-24	02:00:00	IPR	International former former cultural history. Fear trial view follow skill pattern option wife.	\N	\N	1	9
184	2020-02-25	05:00:00	IPR	Long available share artist add change news girl. Throw our miss church director. Street also impact give. Student trial seven everyone focus.	\N	\N	1	9
185	2020-02-26	04:00:00	Test task-1260	Suffer we mother laugh argue positive. Exist tend process once mention long difficult.	\N	1	2	9
186	2020-02-28	03:00:00	IPR	Picture data manage yes. Face maybe any space. Performance teach about goal.	\N	\N	1	9
187	2020-03-02	03:00:00	IPR	Look word day third art air space. Song hope rest before say provide.	\N	\N	1	9
188	2020-03-03	04:00:00	IPR	Who sense sure result. Here available account street. Relationship glass newspaper various travel before.	\N	\N	1	9
189	2020-01-30	04:00:00	Test task-3531	Western face human. Pretty which central region. Country themselves exist.\nAbove again political big dog. Risk seat staff base stay church.	\N	3	2	10
190	2020-01-31	05:00:00	IPR	Them small for. City role doctor town. Property class middle can catch long.	\N	\N	1	10
191	2020-02-01	04:00:00	Test task-2326	Some middle wear nor. Nearly training whom plan science fire talk. Itself somebody form out evening physical speak event.	\N	3	2	10
192	2020-02-02	03:00:00	IPR	Knowledge job Democrat raise concern body course. Movie summer matter study mean physical.	\N	\N	1	10
193	2020-02-03	02:00:00	Test task-4578	Administration agree during own and guess personal. Player seek benefit say former six room his. Still pick argue.	\N	3	2	10
194	2020-02-04	02:00:00	IPR	Third charge low truth rule thought get. Rich statement itself. Purpose condition recent you put his gun. Action grow season physical probably.	\N	\N	1	10
195	2020-02-05	02:00:00	IPR	Value wrong discuss wife. Road improve ago system toward between.\nOut during such size direction among. Usually talk travel bed car general.	\N	\N	1	10
196	2020-02-06	03:00:00	Test task-2697	Stop Mr people air food something front. Piece else debate perhaps special star much. Beyond occur sign. Item job amount what cell.	\N	3	2	10
197	2020-02-07	05:00:00	IPR	Eight speech eat from less. Choice skin travel newspaper newspaper return fight.	\N	\N	1	10
198	2020-02-08	04:00:00	Test task-2304	Out anyone door.\nBig around police fast station but. Blue place air race each produce edge.	\N	3	2	10
199	2020-02-09	05:00:00	IPR	Dinner nor law be address.	\N	\N	1	10
200	2020-02-10	04:00:00	Test task-4874	Bed everything resource really if set nearly your. Again figure capital paper.\nDifferent by floor per meet save. Nice agree theory hit.	\N	3	2	10
201	2020-02-11	03:00:00	Test task-2903	Design history what dark line movement. Consider place control crime price federal.	\N	3	2	10
202	2020-02-12	04:00:00	Test task-2480	Glass apply community thank show sister. Question operation democratic get who create reflect. Bring adult Republican public career art though.	\N	3	2	10
203	2020-02-13	05:00:00	IPR	Special office area night seat alone. Human great remember. Center speak personal live. Notice interview central improve off interest.	\N	\N	1	10
204	2020-02-14	04:00:00	Test task-1903	Kitchen question free successful. Moment hit firm organization.	\N	3	2	10
205	2020-02-15	03:00:00	Test task-2396	From say child job beautiful. Often fact recent despite few stand.	\N	3	2	10
206	2020-02-16	03:00:00	Test task-1658	Risk recently girl near go nature spring. Trade blood also style drive various anything.	\N	3	2	10
207	2020-02-17	04:00:00	Test task-3733	Operation special street young. Value out night teach force.	\N	3	2	10
208	2020-02-18	05:00:00	IPR	Land writer build investment page mouth live open. Natural finally character family admit age.	\N	\N	1	10
209	2020-02-19	02:00:00	Test task-2180	Window great war others step.\nSection at easy. Very attention note drug her mind participant compare.	\N	3	2	10
210	2020-02-20	05:00:00	IPR	Without nice call herself reason. Would month provide sister.	\N	\N	1	10
211	2020-02-21	02:00:00	Test task-1262	City painting remain both let bill. Policy almost discover as color.	\N	3	2	10
212	2020-02-22	03:00:00	Test task-3143	Hour thing despite economic more. Team course gun property.	\N	3	2	10
213	2020-02-23	02:00:00	Test task-1712	Customer inside meeting project matter central difficult never. New church six per so. Personal whose home.	\N	3	2	10
214	2020-02-24	04:00:00	Test task-4621	Fill eye truth back. Turn air country product back surface Mr. Science daughter agreement husband message lot standard.	\N	3	2	10
215	2020-02-25	04:00:00	Test task-2295	Agent new Mrs child. World find quickly think. Discussion themselves once piece four.\nDescribe especially maybe field industry.	\N	3	2	10
216	2020-02-26	05:00:00	IPR	Building least fly response answer arrive. Soon order miss carry picture. Hear human read box where everybody attorney.	\N	\N	1	10
217	2020-02-28	02:00:00	IPR	Somebody tough western everybody opportunity coach. Direction professor magazine left. Until else give personal.	\N	\N	1	10
218	2020-03-01	03:00:00	IPR	No more growth history. Turn herself end.\nEspecially market agreement star something participant writer.	\N	\N	1	10
219	2020-03-02	05:00:00	IPR	General technology just pull with. Set know fine focus.	\N	\N	1	10
220	2020-03-03	03:00:00	IPR	Crime we wonder about need clearly. Rise before east so series as outside serious.	\N	\N	1	10
\.


--
-- Data for Name: dailyplan; Type: TABLE DATA; Schema: public; Owner: user
--

COPY public.dailyplan (id, date, estimated_time, deleted_at, project_id, vacancy_id, worker_id) FROM stdin;
1	2020-01-30	08:00:00	\N	5	2	4
2	2020-01-31	08:00:00	\N	5	2	4
3	2020-02-01	08:00:00	\N	5	2	4
4	2020-02-02	08:00:00	\N	5	2	4
5	2020-02-03	08:00:00	\N	5	2	4
6	2020-02-04	08:00:00	\N	5	2	4
7	2020-02-05	08:00:00	\N	5	2	4
8	2020-02-06	08:00:00	\N	5	2	4
9	2020-02-07	08:00:00	\N	5	2	4
10	2020-02-08	08:00:00	\N	5	2	4
11	2020-02-09	08:00:00	\N	5	2	4
12	2020-02-10	08:00:00	\N	5	2	4
13	2020-02-11	08:00:00	\N	5	2	4
14	2020-02-12	08:00:00	\N	5	2	4
15	2020-02-13	08:00:00	\N	5	2	4
16	2020-02-14	08:00:00	\N	5	2	4
17	2020-01-30	08:00:00	\N	1	2	5
18	2020-01-31	08:00:00	\N	1	2	5
19	2020-02-01	08:00:00	\N	1	2	5
20	2020-02-02	08:00:00	\N	1	2	5
21	2020-02-03	08:00:00	\N	1	2	5
22	2020-02-04	08:00:00	\N	1	2	5
23	2020-02-05	08:00:00	\N	1	2	5
24	2020-02-06	08:00:00	\N	1	2	5
25	2020-02-07	08:00:00	\N	1	2	5
26	2020-02-08	08:00:00	\N	1	2	5
27	2020-02-09	08:00:00	\N	1	2	5
28	2020-02-10	08:00:00	\N	1	2	5
29	2020-02-11	08:00:00	\N	1	2	5
30	2020-02-12	08:00:00	\N	1	2	5
31	2020-02-13	08:00:00	\N	1	2	5
32	2020-02-14	08:00:00	\N	1	2	5
33	2020-02-15	08:00:00	\N	4	2	5
34	2020-02-16	08:00:00	\N	4	2	5
35	2020-02-17	08:00:00	\N	4	2	5
36	2020-02-18	08:00:00	\N	4	2	5
37	2020-02-19	08:00:00	\N	4	2	5
38	2020-02-20	08:00:00	\N	4	2	5
39	2020-02-21	08:00:00	\N	4	2	5
40	2020-02-22	08:00:00	\N	4	2	5
41	2020-02-23	08:00:00	\N	4	2	5
42	2020-02-24	08:00:00	\N	4	2	5
43	2020-02-25	08:00:00	\N	4	2	5
44	2020-02-26	08:00:00	\N	4	2	5
45	2020-02-27	08:00:00	\N	4	2	5
46	2020-02-28	08:00:00	\N	4	2	5
47	2020-02-29	08:00:00	\N	4	2	5
48	2020-03-01	08:00:00	\N	4	2	5
49	2020-03-02	08:00:00	\N	4	2	5
50	2020-03-03	08:00:00	\N	4	2	5
51	2020-01-30	08:00:00	\N	3	2	7
52	2020-01-31	08:00:00	\N	3	2	7
53	2020-02-01	08:00:00	\N	3	2	7
54	2020-02-02	08:00:00	\N	3	2	7
55	2020-02-03	08:00:00	\N	3	2	7
56	2020-02-04	08:00:00	\N	3	2	7
57	2020-02-05	08:00:00	\N	3	2	7
58	2020-02-06	08:00:00	\N	3	2	7
59	2020-02-07	08:00:00	\N	3	2	7
60	2020-02-08	08:00:00	\N	3	2	7
61	2020-02-09	08:00:00	\N	3	2	7
62	2020-02-10	08:00:00	\N	3	2	7
63	2020-02-11	08:00:00	\N	3	2	7
64	2020-02-12	08:00:00	\N	3	2	7
65	2020-02-13	08:00:00	\N	3	2	7
66	2020-02-14	08:00:00	\N	3	2	7
67	2020-02-15	08:00:00	\N	2	2	7
68	2020-02-16	08:00:00	\N	2	2	7
69	2020-02-17	08:00:00	\N	2	2	7
70	2020-02-18	08:00:00	\N	2	2	7
71	2020-02-19	08:00:00	\N	2	2	7
72	2020-02-20	08:00:00	\N	2	2	7
73	2020-02-21	08:00:00	\N	2	2	7
74	2020-02-22	08:00:00	\N	2	2	7
75	2020-02-23	08:00:00	\N	2	2	7
76	2020-02-24	08:00:00	\N	2	2	7
77	2020-02-25	08:00:00	\N	2	2	7
78	2020-02-26	08:00:00	\N	2	2	7
79	2020-02-27	08:00:00	\N	2	2	7
80	2020-02-28	08:00:00	\N	2	2	7
81	2020-02-29	08:00:00	\N	2	2	7
82	2020-03-01	08:00:00	\N	2	2	7
83	2020-03-02	08:00:00	\N	2	2	7
84	2020-03-03	08:00:00	\N	2	2	7
85	2020-01-30	08:00:00	\N	2	2	8
86	2020-01-31	08:00:00	\N	2	2	8
87	2020-02-01	08:00:00	\N	2	2	8
88	2020-02-02	08:00:00	\N	2	2	8
89	2020-02-03	08:00:00	\N	2	2	8
90	2020-02-04	08:00:00	\N	2	2	8
91	2020-02-05	08:00:00	\N	2	2	8
92	2020-02-06	08:00:00	\N	2	2	8
93	2020-02-07	08:00:00	\N	2	2	8
94	2020-02-08	08:00:00	\N	2	2	8
95	2020-02-09	08:00:00	\N	2	2	8
96	2020-02-10	08:00:00	\N	2	2	8
97	2020-02-11	08:00:00	\N	2	2	8
98	2020-02-12	08:00:00	\N	2	2	8
99	2020-02-13	08:00:00	\N	2	2	8
100	2020-02-14	08:00:00	\N	2	2	8
101	2020-02-15	08:00:00	\N	1	2	8
102	2020-02-16	08:00:00	\N	1	2	8
103	2020-02-17	08:00:00	\N	1	2	8
104	2020-02-18	08:00:00	\N	1	2	8
105	2020-02-19	08:00:00	\N	1	2	8
106	2020-02-20	08:00:00	\N	1	2	8
107	2020-02-21	08:00:00	\N	1	2	8
108	2020-02-22	08:00:00	\N	1	2	8
109	2020-02-23	08:00:00	\N	1	2	8
110	2020-02-24	08:00:00	\N	1	2	8
111	2020-02-25	08:00:00	\N	1	2	8
112	2020-02-26	08:00:00	\N	1	2	8
113	2020-02-27	08:00:00	\N	1	2	8
114	2020-02-28	08:00:00	\N	1	2	8
115	2020-02-29	08:00:00	\N	1	2	8
116	2020-03-01	08:00:00	\N	1	2	8
117	2020-03-02	08:00:00	\N	1	2	8
118	2020-03-03	08:00:00	\N	1	2	8
119	2020-01-30	04:00:00	\N	1	3	9
120	2020-01-31	04:00:00	\N	1	3	9
121	2020-02-01	04:00:00	\N	1	3	9
122	2020-02-02	04:00:00	\N	1	3	9
123	2020-02-03	04:00:00	\N	1	3	9
124	2020-02-04	04:00:00	\N	1	3	9
125	2020-02-05	04:00:00	\N	1	3	9
126	2020-02-06	04:00:00	\N	1	3	9
127	2020-02-07	04:00:00	\N	1	3	9
128	2020-02-08	04:00:00	\N	1	3	9
129	2020-02-09	04:00:00	\N	1	3	9
130	2020-02-10	04:00:00	\N	1	3	9
131	2020-02-11	04:00:00	\N	1	3	9
132	2020-02-12	04:00:00	\N	1	3	9
133	2020-02-13	04:00:00	\N	1	3	9
134	2020-02-14	04:00:00	\N	1	3	9
135	2020-02-15	04:00:00	\N	1	3	9
136	2020-02-16	04:00:00	\N	1	3	9
137	2020-02-17	04:00:00	\N	1	3	9
138	2020-02-18	04:00:00	\N	1	3	9
139	2020-02-19	04:00:00	\N	1	3	9
140	2020-02-20	04:00:00	\N	1	3	9
141	2020-02-21	04:00:00	\N	1	3	9
142	2020-02-22	04:00:00	\N	1	3	9
143	2020-02-23	04:00:00	\N	1	3	9
144	2020-02-24	04:00:00	\N	1	3	9
145	2020-02-25	04:00:00	\N	1	3	9
146	2020-02-26	04:00:00	\N	1	3	9
147	2020-01-30	04:00:00	\N	3	3	10
148	2020-01-31	04:00:00	\N	3	3	10
149	2020-02-01	04:00:00	\N	3	3	10
150	2020-02-02	04:00:00	\N	3	3	10
151	2020-02-03	04:00:00	\N	3	3	10
152	2020-02-04	04:00:00	\N	3	3	10
153	2020-02-05	04:00:00	\N	3	3	10
154	2020-02-06	04:00:00	\N	3	3	10
155	2020-02-07	04:00:00	\N	3	3	10
156	2020-02-08	04:00:00	\N	3	3	10
157	2020-02-09	04:00:00	\N	3	3	10
158	2020-02-10	04:00:00	\N	3	3	10
159	2020-02-11	04:00:00	\N	3	3	10
160	2020-02-12	04:00:00	\N	3	3	10
161	2020-02-13	04:00:00	\N	3	3	10
162	2020-02-14	04:00:00	\N	3	3	10
163	2020-02-15	04:00:00	\N	3	3	10
164	2020-02-16	04:00:00	\N	3	3	10
165	2020-02-17	04:00:00	\N	3	3	10
166	2020-02-18	04:00:00	\N	3	3	10
167	2020-02-19	04:00:00	\N	3	3	10
168	2020-02-20	04:00:00	\N	3	3	10
169	2020-02-21	04:00:00	\N	3	3	10
170	2020-02-22	04:00:00	\N	3	3	10
171	2020-02-23	04:00:00	\N	3	3	10
172	2020-02-24	04:00:00	\N	3	3	10
173	2020-02-25	04:00:00	\N	3	3	10
174	2020-02-26	04:00:00	\N	3	3	10
\.


--
-- Data for Name: project; Type: TABLE DATA; Schema: public; Owner: user
--

COPY public.project (id, name, deleted_at) FROM stdin;
1	Project Galaxy	\N
2	Eco Project	\N
3	Gemstone Project	\N
4	Axion Project	\N
5	Appliance Project	\N
6	Project Red	\N
\.


--
-- Data for Name: projectworker; Type: TABLE DATA; Schema: public; Owner: user
--

COPY public.projectworker (id, start_date, end_date, is_parttime, deleted_at, project_id, vacancy_on_project_id, worker_id) FROM stdin;
1	2020-01-30	2020-02-20	f	\N	1	1	1
2	2020-01-30	2020-02-20	f	\N	2	1	2
3	2020-01-30	2020-02-20	f	\N	3	1	1
4	2020-01-30	2020-02-20	f	\N	4	1	2
5	2020-01-30	2020-02-20	f	\N	5	1	1
6	2020-01-30	2020-02-20	f	\N	6	1	3
7	2020-01-30	2020-02-14	f	\N	1	2	5
8	2020-01-30	2020-02-14	f	\N	2	2	8
9	2020-01-30	2020-02-14	f	\N	3	2	7
10	2020-01-30	2020-02-14	f	\N	4	2	8
11	2020-01-30	2020-02-14	f	\N	5	2	4
12	2020-01-30	2020-02-14	f	\N	6	2	5
13	2020-01-30	2020-02-19	t	\N	1	3	9
14	2020-01-30	2020-02-19	t	\N	2	3	9
15	2020-01-30	2020-02-19	t	\N	3	3	10
16	2020-02-19	2020-02-29	f	\N	1	1	2
17	2020-02-19	2020-02-29	f	\N	2	1	1
18	2020-02-19	2020-02-29	f	\N	3	1	1
19	2020-02-19	2020-02-29	f	\N	4	1	1
20	2020-02-19	2020-02-29	f	\N	5	1	1
21	2020-02-19	2020-02-29	f	\N	6	1	1
22	2020-02-13	2020-03-04	f	\N	1	2	8
23	2020-02-13	2020-03-04	f	\N	2	2	7
24	2020-02-13	2020-03-04	f	\N	3	2	7
25	2020-02-13	2020-03-04	f	\N	4	2	5
26	2020-02-13	2020-03-04	f	\N	5	2	7
27	2020-02-13	2020-03-04	f	\N	6	2	5
28	2020-02-18	2020-02-26	t	\N	1	3	9
29	2020-02-18	2020-02-26	f	\N	2	3	9
30	2020-02-18	2020-02-26	t	\N	3	3	10
\.


--
-- Data for Name: vacancy; Type: TABLE DATA; Schema: public; Owner: user
--

COPY public.vacancy (id, name, deleted_at) FROM stdin;
1	PM	\N
2	Developer	\N
3	QA	\N
\.


--
-- Data for Name: worker; Type: TABLE DATA; Schema: public; Owner: user
--

COPY public.worker (id, name, deleted_at) FROM stdin;
1	Артемьев Филипп Петрович	\N
2	Блинов Марк Григорьевич	\N
3	Андрусейко Устин Алексеевич	\N
4	Борисов Ян Евгеньевич	\N
5	Лаврентьев Павел Андреевич	\N
6	Полищук Савва Григорьевич	\N
7	Фролов Гавриил Валерьевич	\N
8	Шарапов Донат Вадимович	\N
9	Некрасов Чарльз Алексеевич	\N
10	Шкраба Тимофей Васильевич	\N
\.


--
-- Data for Name: worktype; Type: TABLE DATA; Schema: public; Owner: user
--

COPY public.worktype (id, name, deleted_at) FROM stdin;
1	IPR	\N
2	Project	\N
3	Help on presales project	\N
\.


--
-- Name: dailylog_id_seq; Type: SEQUENCE SET; Schema: public; Owner: user
--

SELECT pg_catalog.setval('public.dailylog_id_seq', 220, true);


--
-- Name: dailyplan_id_seq; Type: SEQUENCE SET; Schema: public; Owner: user
--

SELECT pg_catalog.setval('public.dailyplan_id_seq', 174, true);


--
-- Name: project_id_seq; Type: SEQUENCE SET; Schema: public; Owner: user
--

SELECT pg_catalog.setval('public.project_id_seq', 6, true);


--
-- Name: projectworker_id_seq; Type: SEQUENCE SET; Schema: public; Owner: user
--

SELECT pg_catalog.setval('public.projectworker_id_seq', 30, true);


--
-- Name: vacancy_id_seq; Type: SEQUENCE SET; Schema: public; Owner: user
--

SELECT pg_catalog.setval('public.vacancy_id_seq', 3, true);


--
-- Name: worker_id_seq; Type: SEQUENCE SET; Schema: public; Owner: user
--

SELECT pg_catalog.setval('public.worker_id_seq', 10, true);


--
-- Name: worktype_id_seq; Type: SEQUENCE SET; Schema: public; Owner: user
--

SELECT pg_catalog.setval('public.worktype_id_seq', 3, true);


--
-- Name: dailylog dailylog_pkey; Type: CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.dailylog
    ADD CONSTRAINT dailylog_pkey PRIMARY KEY (id);


--
-- Name: dailyplan dailyplan_pkey; Type: CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.dailyplan
    ADD CONSTRAINT dailyplan_pkey PRIMARY KEY (id);


--
-- Name: project project_pkey; Type: CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.project
    ADD CONSTRAINT project_pkey PRIMARY KEY (id);


--
-- Name: projectworker projectworker_pkey; Type: CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.projectworker
    ADD CONSTRAINT projectworker_pkey PRIMARY KEY (id);


--
-- Name: vacancy vacancy_pkey; Type: CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.vacancy
    ADD CONSTRAINT vacancy_pkey PRIMARY KEY (id);


--
-- Name: worker worker_pkey; Type: CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.worker
    ADD CONSTRAINT worker_pkey PRIMARY KEY (id);


--
-- Name: worktype worktype_pkey; Type: CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.worktype
    ADD CONSTRAINT worktype_pkey PRIMARY KEY (id);


--
-- Name: dailylog_project_id_10fa86f2; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX dailylog_project_id_10fa86f2 ON public.dailylog USING btree (project_id);


--
-- Name: dailylog_work_type_id_95a5c2e8; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX dailylog_work_type_id_95a5c2e8 ON public.dailylog USING btree (work_type_id);


--
-- Name: dailylog_worker_id_d9ae5759; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX dailylog_worker_id_d9ae5759 ON public.dailylog USING btree (worker_id);


--
-- Name: dailyplan_project_id_1dc41066; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX dailyplan_project_id_1dc41066 ON public.dailyplan USING btree (project_id);


--
-- Name: dailyplan_vacancy_id_f3789650; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX dailyplan_vacancy_id_f3789650 ON public.dailyplan USING btree (vacancy_id);


--
-- Name: dailyplan_worker_id_264f1a60; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX dailyplan_worker_id_264f1a60 ON public.dailyplan USING btree (worker_id);


--
-- Name: projectworker_project_id_9d707b5a; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX projectworker_project_id_9d707b5a ON public.projectworker USING btree (project_id);


--
-- Name: projectworker_vacancy_on_project_id_fa6f1596; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX projectworker_vacancy_on_project_id_fa6f1596 ON public.projectworker USING btree (vacancy_on_project_id);


--
-- Name: projectworker_worker_id_d28248f6; Type: INDEX; Schema: public; Owner: user
--

CREATE INDEX projectworker_worker_id_d28248f6 ON public.projectworker USING btree (worker_id);


--
-- Name: dailylog dailylog_project_id_10fa86f2_fk_project_id; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.dailylog
    ADD CONSTRAINT dailylog_project_id_10fa86f2_fk_project_id FOREIGN KEY (project_id) REFERENCES public.project(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: dailylog dailylog_work_type_id_95a5c2e8_fk_worktype_id; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.dailylog
    ADD CONSTRAINT dailylog_work_type_id_95a5c2e8_fk_worktype_id FOREIGN KEY (work_type_id) REFERENCES public.worktype(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: dailylog dailylog_worker_id_d9ae5759_fk_worker_id; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.dailylog
    ADD CONSTRAINT dailylog_worker_id_d9ae5759_fk_worker_id FOREIGN KEY (worker_id) REFERENCES public.worker(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: dailyplan dailyplan_project_id_1dc41066_fk_project_id; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.dailyplan
    ADD CONSTRAINT dailyplan_project_id_1dc41066_fk_project_id FOREIGN KEY (project_id) REFERENCES public.project(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: dailyplan dailyplan_vacancy_id_f3789650_fk_vacancy_id; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.dailyplan
    ADD CONSTRAINT dailyplan_vacancy_id_f3789650_fk_vacancy_id FOREIGN KEY (vacancy_id) REFERENCES public.vacancy(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: dailyplan dailyplan_worker_id_264f1a60_fk_worker_id; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.dailyplan
    ADD CONSTRAINT dailyplan_worker_id_264f1a60_fk_worker_id FOREIGN KEY (worker_id) REFERENCES public.worker(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: projectworker projectworker_project_id_9d707b5a_fk_project_id; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.projectworker
    ADD CONSTRAINT projectworker_project_id_9d707b5a_fk_project_id FOREIGN KEY (project_id) REFERENCES public.project(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: projectworker projectworker_vacancy_on_project_i_fa6f1596_fk_vaca; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.projectworker
    ADD CONSTRAINT projectworker_vacancy_on_project_i_fa6f1596_fk_vaca FOREIGN KEY (vacancy_on_project_id) REFERENCES public.vacancy(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: projectworker projectworker_worker_id_d28248f6_fk_worker_id; Type: FK CONSTRAINT; Schema: public; Owner: user
--

ALTER TABLE ONLY public.projectworker
    ADD CONSTRAINT projectworker_worker_id_d28248f6_fk_worker_id FOREIGN KEY (worker_id) REFERENCES public.worker(id) DEFERRABLE INITIALLY DEFERRED;


--
-- PostgreSQL database dump complete
--

