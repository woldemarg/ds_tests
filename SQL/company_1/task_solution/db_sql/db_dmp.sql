BEGIN TRANSACTION;
DROP TABLE IF EXISTS "medicine";
CREATE TABLE IF NOT EXISTS "medicine" (
	"VISIT_ID"	INTEGER NOT NULL,
	"DIAG_ID"	INTEGER NOT NULL,
	"WORKER_ID"	INTEGER NOT NULL,
	"VISIT_DATE"	TEXT NOT NULL,
	"RECOVERY_DATE"	TEXT NOT NULL,
	PRIMARY KEY("VISIT_ID"),
	FOREIGN KEY("DIAG_ID") REFERENCES "diagnosis"("DIAG_ID"),	
	FOREIGN KEY("WORKER_ID") REFERENCES "workers"("WORKER_ID")
);
DROP TABLE IF EXISTS "diagnosis";
CREATE TABLE IF NOT EXISTS "diagnosis" (
	"DIAG_ID"	INTEGER NOT NULL,
	"DESCR"	TEXT NOT NULL,
	"TIME_EST"	TEXT NOT NULL,
	PRIMARY KEY("DIAG_ID")
);
DROP TABLE IF EXISTS "job";
CREATE TABLE IF NOT EXISTS "job" (
	"POSITION_ID"	INTEGER NOT NULL,
	"WORKER_ID"	INTEGER NOT NULL,
	"POSITION"	TEXT NOT NULL,
	"SALARY"	NUMERIC NOT NULL,
	"FROM_DATE"	TEXT NOT NULL,
	"OFFICE"	TEXT NOT NULL,
	"OFFICE_CITY"	TEXT NOT NULL,
	"TO_DATE"	TEXT,
	"ACTIVE_INDCTR"	TEXT NOT NULL,
	"MANAGER_ID"	INTEGER,
	PRIMARY KEY("POSITION_ID", "WORKER_ID")
	FOREIGN KEY("WORKER_ID") REFERENCES "workers"("WORKER_ID")	
);
DROP TABLE IF EXISTS "workers";
CREATE TABLE IF NOT EXISTS "workers" (
	"WORKER_ID"	INTEGER NOT NULL,
	"FIRST_NAME"	TEXT NOT NULL,
	"LAST_NAME"	TEXT NOT NULL,
	"GENDER"	TEXT NOT NULL,
	"DOB"	TEXT NOT NULL,
	"CONTACT_ID"	INTEGER NOT NULL,
	"MANAGER_ID"	INTEGER NOT NULL,
	PRIMARY KEY("WORKER_ID"),
	FOREIGN KEY("CONTACT_ID") REFERENCES "contacts"("CONTACT_ID"),
	FOREIGN KEY("MANAGER_ID") REFERENCES "workers"("WORKER_ID")
);
DROP TABLE IF EXISTS "contacts";
CREATE TABLE IF NOT EXISTS "contacts" (
	"CONTACT_ID"	INTEGER NOT NULL,
	"WORK_PHONE"	TEXT NOT NULL,
	"ADDR1"	TEXT NOT NULL,
	"ADDR2"	TEXT,
	"CITY"	TEXT NOT NULL,
	"ZIP"	INTEGER NOT NULL,
	"UPDATED"	TEXT,
	"HOME_PHONE"	INTEGER NOT NULL,
	PRIMARY KEY("CONTACT_ID")
);
INSERT INTO "medicine" ("VISIT_ID","DIAG_ID","WORKER_ID","VISIT_DATE","RECOVERY_DATE") VALUES (5001001,3001021,6001012,'08-Aug-11','08-Sep-11');
INSERT INTO "medicine" ("VISIT_ID","DIAG_ID","WORKER_ID","VISIT_DATE","RECOVERY_DATE") VALUES (5001002,3001002,6001012,'12-Aug-11','08-Sep-11');
INSERT INTO "medicine" ("VISIT_ID","DIAG_ID","WORKER_ID","VISIT_DATE","RECOVERY_DATE") VALUES (5001003,3001017,6001012,'15-Aug-11','08-Sep-11');
INSERT INTO "medicine" ("VISIT_ID","DIAG_ID","WORKER_ID","VISIT_DATE","RECOVERY_DATE") VALUES (5001004,3001018,6001003,'11-Sep-11','13-Sep-11');
INSERT INTO "medicine" ("VISIT_ID","DIAG_ID","WORKER_ID","VISIT_DATE","RECOVERY_DATE") VALUES (5001005,3001037,6001005,'12-Sep-11','13-Nov-11');
INSERT INTO "medicine" ("VISIT_ID","DIAG_ID","WORKER_ID","VISIT_DATE","RECOVERY_DATE") VALUES (5001006,3001009,6001003,'27-Sep-11','01-Oct-11');
INSERT INTO "medicine" ("VISIT_ID","DIAG_ID","WORKER_ID","VISIT_DATE","RECOVERY_DATE") VALUES (5001007,3001005,6001034,'15-Oct-11','28-Oct-11');
INSERT INTO "medicine" ("VISIT_ID","DIAG_ID","WORKER_ID","VISIT_DATE","RECOVERY_DATE") VALUES (5001008,3001002,6001034,'18-Oct-11','23-Oct-11');
INSERT INTO "medicine" ("VISIT_ID","DIAG_ID","WORKER_ID","VISIT_DATE","RECOVERY_DATE") VALUES (5001009,3001006,6001026,'25-Oct-11','29-Oct-11');
INSERT INTO "medicine" ("VISIT_ID","DIAG_ID","WORKER_ID","VISIT_DATE","RECOVERY_DATE") VALUES (5001010,3001007,6001026,'02-Nov-11','03-Nov-11');
INSERT INTO "medicine" ("VISIT_ID","DIAG_ID","WORKER_ID","VISIT_DATE","RECOVERY_DATE") VALUES (5001011,3001016,6001019,'07-Nov-11','11-Nov-11');
INSERT INTO "medicine" ("VISIT_ID","DIAG_ID","WORKER_ID","VISIT_DATE","RECOVERY_DATE") VALUES (5001012,3001024,6001021,'07-Nov-11','19-Nov-11');
INSERT INTO "medicine" ("VISIT_ID","DIAG_ID","WORKER_ID","VISIT_DATE","RECOVERY_DATE") VALUES (5001013,3001024,6001022,'07-Nov-11','19-Nov-11');
INSERT INTO "medicine" ("VISIT_ID","DIAG_ID","WORKER_ID","VISIT_DATE","RECOVERY_DATE") VALUES (5001014,3001007,6001022,'09-Nov-11','14-Nov-11');
INSERT INTO "medicine" ("VISIT_ID","DIAG_ID","WORKER_ID","VISIT_DATE","RECOVERY_DATE") VALUES (5001015,3001025,6001009,'11-Nov-11','13-Nov-11');
INSERT INTO "diagnosis" ("DIAG_ID","DESCR","TIME_EST") VALUES (3001001,'Hip ТВ-hist POS','31-May-98');
INSERT INTO "diagnosis" ("DIAG_ID","DESCR","TIME_EST") VALUES (3001002,'Hip TB-oth test POS','22-Aug-12');
INSERT INTO "diagnosis" ("DIAG_ID","DESCR","TIME_EST") VALUES (3001003,'Knee ТВ-exam NOS','22-Aug-12');
INSERT INTO "diagnosis" ("DIAG_ID","DESCR","TIME_EST") VALUES (3001004,'Knee ТВ-no exam','27-Aug-12');
INSERT INTO "diagnosis" ("DIAG_ID","DESCR","TIME_EST") VALUES (3001005,'Limb bone ТВ-hist POS','17-Aug-12');
INSERT INTO "diagnosis" ("DIAG_ID","DESCR","TIME_EST") VALUES (3001006,'Limb bone TB-oth test','27-May-12');
INSERT INTO "diagnosis" ("DIAG_ID","DESCR","TIME_EST") VALUES (3001007,'Mastoid ТВ-exam NOS','27-May-12');
INSERT INTO "diagnosis" ("DIAG_ID","DESCR","TIME_EST") VALUES (3001008,'Mastoid ТВ-no exam','27-Jul-12');
INSERT INTO "diagnosis" ("DIAG_ID","DESCR","TIME_EST") VALUES (3001009,'Large intestine CA NE','08-Aug-12');
INSERT INTO "diagnosis" ("DIAG_ID","DESCR","TIME_EST") VALUES (3001010,'Colon CA NOS','08-Aug-12');
INSERT INTO "diagnosis" ("DIAG_ID","DESCR","TIME_EST") VALUES (3001011,'Rectosigmoid junction CA','18-Jul-12');
INSERT INTO "diagnosis" ("DIAG_ID","DESCR","TIME_EST") VALUES (3001012,'Maxillary sinus CA','28-Mar-12');
INSERT INTO "diagnosis" ("DIAG_ID","DESCR","TIME_EST") VALUES (3001013,'Ethmoid sinus CA','28-Mar-12');
INSERT INTO "diagnosis" ("DIAG_ID","DESCR","TIME_EST") VALUES (3001014,'Frontal sinus CA','22-Mar-12');
INSERT INTO "diagnosis" ("DIAG_ID","DESCR","TIME_EST") VALUES (3001015,'Sphenoid sinus CA','28-Apr-12');
INSERT INTO "job" ("POSITION_ID","WORKER_ID","POSITION","SALARY","FROM_DATE","OFFICE","OFFICE_CITY","TO_DATE","ACTIVE_INDCTR","MANAGER_ID") VALUES (4001008,6001037,'C# DEVELOPER',534.96,'19-Mar-09','TIME IS MONEY','SEBEWAING',NULL,'Y',4001009);
INSERT INTO "job" ("POSITION_ID","WORKER_ID","POSITION","SALARY","FROM_DATE","OFFICE","OFFICE_CITY","TO_DATE","ACTIVE_INDCTR","MANAGER_ID") VALUES (4001008,6001038,'C# DEVELOPER',678.73,'18-Jun-08','CRYSTALBRAIN','UNIONVILLE',NULL,'Y',4001009);
INSERT INTO "job" ("POSITION_ID","WORKER_ID","POSITION","SALARY","FROM_DATE","OFFICE","OFFICE_CITY","TO_DATE","ACTIVE_INDCTR","MANAGER_ID") VALUES (4001008,6001039,'C# DEVELOPER',1102.22,'22-Feb-04','CRYSTALBRAIN','UNIONVILLE',NULL,'Y',4001009);
INSERT INTO "job" ("POSITION_ID","WORKER_ID","POSITION","SALARY","FROM_DATE","OFFICE","OFFICE_CITY","TO_DATE","ACTIVE_INDCTR","MANAGER_ID") VALUES (4001009,6001040,'C# DEVELOPER TEAMLEAD',1021.77,'14-Jan-07','CRYSTALBRAIN','UNIONVILLE',NULL,'Y',4001011);
INSERT INTO "job" ("POSITION_ID","WORKER_ID","POSITION","SALARY","FROM_DATE","OFFICE","OFFICE_CITY","TO_DATE","ACTIVE_INDCTR","MANAGER_ID") VALUES (4001010,6001041,'WEB DESIGNER',802.22,'08-Aug-08','CRYSTALBRAIN','UNIONVILLE',NULL,'Y',4001003);
INSERT INTO "job" ("POSITION_ID","WORKER_ID","POSITION","SALARY","FROM_DATE","OFFICE","OFFICE_CITY","TO_DATE","ACTIVE_INDCTR","MANAGER_ID") VALUES (4001010,6001042,'WEB DESIGNER',615.77,'01-Nov-10','CRYSTALBRAIN','UNIONVILLE',NULL,'Y',4001003);
INSERT INTO "job" ("POSITION_ID","WORKER_ID","POSITION","SALARY","FROM_DATE","OFFICE","OFFICE_CITY","TO_DATE","ACTIVE_INDCTR","MANAGER_ID") VALUES (4001010,6001043,'WEB DESIGNER',706.21,'09-Nov-09','TIME IS MONEY','SEBEWAING',NULL,'Y',4001011);
INSERT INTO "job" ("POSITION_ID","WORKER_ID","POSITION","SALARY","FROM_DATE","OFFICE","OFFICE_CITY","TO_DATE","ACTIVE_INDCTR","MANAGER_ID") VALUES (4001001,6001001,'AUTOMATION QA ENGINEER',621.44,'10-Jun-09','CRYSTALBRAIN','UNIONVILLE',NULL,'Y',4001002);
INSERT INTO "job" ("POSITION_ID","WORKER_ID","POSITION","SALARY","FROM_DATE","OFFICE","OFFICE_CITY","TO_DATE","ACTIVE_INDCTR","MANAGER_ID") VALUES (4001001,6001002,'AUTOMATION QA ENGINEER',499.34,'19-Mar-12','CRYSTALBRAIN','UNIONVILLE',NULL,'Y',4001002);
INSERT INTO "job" ("POSITION_ID","WORKER_ID","POSITION","SALARY","FROM_DATE","OFFICE","OFFICE_CITY","TO_DATE","ACTIVE_INDCTR","MANAGER_ID") VALUES (4001001,6001003,'AUTOMATION QA ENGINEER',519.21,'01-Nov-11','TIME IS MONEY','SEBEWAING',NULL,'Y',4001002);
INSERT INTO "job" ("POSITION_ID","WORKER_ID","POSITION","SALARY","FROM_DATE","OFFICE","OFFICE_CITY","TO_DATE","ACTIVE_INDCTR","MANAGER_ID") VALUES (4001001,6001004,'AUTOMATION QA ENGINEER',621.17,'18-Sep-09','TIME IS MONEY','SEBEWAING',NULL,'Y',4001002);
INSERT INTO "job" ("POSITION_ID","WORKER_ID","POSITION","SALARY","FROM_DATE","OFFICE","OFFICE_CITY","TO_DATE","ACTIVE_INDCTR","MANAGER_ID") VALUES (4001001,6001005,'AUTOMATION QA ENGINEER',588.21,'21-Sep-11','TIME IS MONEY','SEBEWAING',NULL,'Y',4001002);
INSERT INTO "job" ("POSITION_ID","WORKER_ID","POSITION","SALARY","FROM_DATE","OFFICE","OFFICE_CITY","TO_DATE","ACTIVE_INDCTR","MANAGER_ID") VALUES (4001002,6001006,'AUTOMATION QA TEAMLEAD',979.17,'18-Sep-09','TIME IS MONEY','SEBEWAING',NULL,'Y',4001003);
INSERT INTO "job" ("POSITION_ID","WORKER_ID","POSITION","SALARY","FROM_DATE","OFFICE","OFFICE_CITY","TO_DATE","ACTIVE_INDCTR","MANAGER_ID") VALUES (4001003,6001007,'PRODUCT MANAGER',1132.78,'12-Apr-08','TIME IS MONEY','SEBEWAING',NULL,'Y',NULL);
INSERT INTO "job" ("POSITION_ID","WORKER_ID","POSITION","SALARY","FROM_DATE","OFFICE","OFFICE_CITY","TO_DATE","ACTIVE_INDCTR","MANAGER_ID") VALUES (4001004,6001008,'JAVA DEVELOPER',554.37,'11-Apr-09','CRYSTALBRAIN','UNIONVILLE',NULL,'Y',4001005);
INSERT INTO "workers" ("WORKER_ID","FIRST_NAME","LAST_NAME","GENDER","DOB","CONTACT_ID","MANAGER_ID") VALUES (6001001,'NIKOLA','TESLA','M','27-Sep-86',2001001,6001006);
INSERT INTO "workers" ("WORKER_ID","FIRST_NAME","LAST_NAME","GENDER","DOB","CONTACT_ID","MANAGER_ID") VALUES (6001002,'JANICE','PRILL','F','27-Sep-90',2001002,6001006);
INSERT INTO "workers" ("WORKER_ID","FIRST_NAME","LAST_NAME","GENDER","DOB","CONTACT_ID","MANAGER_ID") VALUES (6001003,'JERI','THOMPSON','M','21-Sep-86',2001003,6001006);
INSERT INTO "workers" ("WORKER_ID","FIRST_NAME","LAST_NAME","GENDER","DOB","CONTACT_ID","MANAGER_ID") VALUES (6001004,'KAREN','DUFTY','F','24-Aug-86',2001004,6001006);
INSERT INTO "workers" ("WORKER_ID","FIRST_NAME","LAST_NAME","GENDER","DOB","CONTACT_ID","MANAGER_ID") VALUES (6001005,'JEFF','WANLESS','M','27-Jun-86',2001005,6001006);
INSERT INTO "workers" ("WORKER_ID","FIRST_NAME","LAST_NAME","GENDER","DOB","CONTACT_ID","MANAGER_ID") VALUES (6001006,'CHRISTINE','BECKER','F','27-Sep-85',2001006,6001007);
INSERT INTO "workers" ("WORKER_ID","FIRST_NAME","LAST_NAME","GENDER","DOB","CONTACT_ID","MANAGER_ID") VALUES (6001007,'CATHY','HEINITZ','F','27-Sep-86',2001007,6001007);
INSERT INTO "workers" ("WORKER_ID","FIRST_NAME","LAST_NAME","GENDER","DOB","CONTACT_ID","MANAGER_ID") VALUES (6001008,'LICI','KATNIK','F','27-Oct-81',2001008,6001018);
INSERT INTO "workers" ("WORKER_ID","FIRST_NAME","LAST_NAME","GENDER","DOB","CONTACT_ID","MANAGER_ID") VALUES (6001009,'TOMMY','HARE','M','13-Sep-85',2001009,6001018);
INSERT INTO "workers" ("WORKER_ID","FIRST_NAME","LAST_NAME","GENDER","DOB","CONTACT_ID","MANAGER_ID") VALUES (6001010,'MATILDA','FINAN','F','21-Jan-86',2001010,6001018);
INSERT INTO "workers" ("WORKER_ID","FIRST_NAME","LAST_NAME","GENDER","DOB","CONTACT_ID","MANAGER_ID") VALUES (6001011,'DAWAN','HARTMAN','M','24-Mar-87',2001011,6001018);
INSERT INTO "workers" ("WORKER_ID","FIRST_NAME","LAST_NAME","GENDER","DOB","CONTACT_ID","MANAGER_ID") VALUES (6001012,'LINDA','WILLIAMS','F','17-Apr-84',2001012,6001018);
INSERT INTO "workers" ("WORKER_ID","FIRST_NAME","LAST_NAME","GENDER","DOB","CONTACT_ID","MANAGER_ID") VALUES (6001013,'DEBRA','SYTRON','F','02-Sep-82',2001013,6001018);
INSERT INTO "workers" ("WORKER_ID","FIRST_NAME","LAST_NAME","GENDER","DOB","CONTACT_ID","MANAGER_ID") VALUES (6001015,'CINDY','USTIN','F','29-Sep-90',2001015,6001018);
INSERT INTO "workers" ("WORKER_ID","FIRST_NAME","LAST_NAME","GENDER","DOB","CONTACT_ID","MANAGER_ID") VALUES (6001016,'HELEN','DECKER','F','17-Feb-86',2001016,6001018);
INSERT INTO "contacts" ("CONTACT_ID","WORK_PHONE","ADDR1","ADDR2","CITY","ZIP","UPDATED","HOME_PHONE") VALUES (2001001,'1812346982','1691 FORESTVILLE RD',NULL,'UNIONVILLE',46246,NULL,135142679);
INSERT INTO "contacts" ("CONTACT_ID","WORK_PHONE","ADDR1","ADDR2","CITY","ZIP","UPDATED","HOME_PHONE") VALUES (2001002,'1812346983','17 S MILLER ST',NULL,'SEBEWAING',46246,'24-Oct-12',135142674);
INSERT INTO "contacts" ("CONTACT_ID","WORK_PHONE","ADDR1","ADDR2","CITY","ZIP","UPDATED","HOME_PHONE") VALUES (2001003,'1812346112','170 S BROWN RD',NULL,'PIGEON',46242,NULL,1235142674);
INSERT INTO "contacts" ("CONTACT_ID","WORK_PHONE","ADDR1","ADDR2","CITY","ZIP","UPDATED","HOME_PHONE") VALUES (2001004,'1812346933','1700 W ACKERMAN RD',NULL,'UNIONVILLE',46221,NULL,1235142847);
INSERT INTO "contacts" ("CONTACT_ID","WORK_PHONE","ADDR1","ADDR2","CITY","ZIP","UPDATED","HOME_PHONE") VALUES (2001005,'1814546922','1706 KIEL RD',NULL,'UNIONVILLE',46221,NULL,1235184671);
INSERT INTO "contacts" ("CONTACT_ID","WORK_PHONE","ADDR1","ADDR2","CITY","ZIP","UPDATED","HOME_PHONE") VALUES (2001006,'1815676944','1710 W DICKERSON RD',NULL,'UNIONVILLE',46221,NULL,123184671);
INSERT INTO "contacts" ("CONTACT_ID","WORK_PHONE","ADDR1","ADDR2","CITY","ZIP","UPDATED","HOME_PHONE") VALUES (2001007,'1813468249','1727 W HOPPE RD',NULL,'UNIONVILLE',46221,NULL,123184671);
INSERT INTO "contacts" ("CONTACT_ID","WORK_PHONE","ADDR1","ADDR2","CITY","ZIP","UPDATED","HOME_PHONE") VALUES (2001008,'1865326982','173 W CASS CITY RD',NULL,'UNIONVILLE',46221,NULL,123184622);
INSERT INTO "contacts" ("CONTACT_ID","WORK_PHONE","ADDR1","ADDR2","CITY","ZIP","UPDATED","HOME_PHONE") VALUES (2001009,'1813468249','1733 ELMWOOD RD','14','UNIONVILLE',46221,NULL,145184621);
INSERT INTO "contacts" ("CONTACT_ID","WORK_PHONE","ADDR1","ADDR2","CITY","ZIP","UPDATED","HOME_PHONE") VALUES (2001010,'1865346182','1744 KIEL RD',NULL,'UNIONVILLE',46221,NULL,145184694);
INSERT INTO "contacts" ("CONTACT_ID","WORK_PHONE","ADDR1","ADDR2","CITY","ZIP","UPDATED","HOME_PHONE") VALUES (2001011,'1813468249','1755 E HOPPE RD','B-19','UNIONVILLE',46221,'24-Oct-11',1451846944);
INSERT INTO "contacts" ("CONTACT_ID","WORK_PHONE","ADDR1","ADDR2","CITY","ZIP","UPDATED","HOME_PHONE") VALUES (2001012,'1865346882','1777 POINTE AUX BARQUES RD',NULL,'UNIONVILLE',46221,'13-Nov-11',1451846978);
INSERT INTO "contacts" ("CONTACT_ID","WORK_PHONE","ADDR1","ADDR2","CITY","ZIP","UPDATED","HOME_PHONE") VALUES (2001013,'1813468249','1755 E HOPPE RD','B-19','UNIONVILLE',46221,'24-Oct-11',1451846926);
INSERT INTO "contacts" ("CONTACT_ID","WORK_PHONE","ADDR1","ADDR2","CITY","ZIP","UPDATED","HOME_PHONE") VALUES (2001014,'1865346962','1777 POINTE AUX BARQUES RD',NULL,'PORTAUSTIN',46221,'13-Nov-11',1451846937);
INSERT INTO "contacts" ("CONTACT_ID","WORK_PHONE","ADDR1","ADDR2","CITY","ZIP","UPDATED","HOME_PHONE") VALUES (2001015,'1815434631','1815 W DICKERSON RD',NULL,'ELKTON',46246,NULL,1471846937);
COMMIT;
