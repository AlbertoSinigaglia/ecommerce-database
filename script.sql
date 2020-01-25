start transaction;
set foreign_key_checks=0;
set sql_mode = "no_auto_value_on_zero";
set autocommit = 0;
set time_zone = "+01:00";

drop table if exists utente;
drop table if exists collaboratore;
drop table if exists cliente;
drop table if exists coupon;
drop table if exists ordine;
drop table if exists dati_fatturazione;
drop table if exists lingua;
drop table if exists prodotto;
drop table if exists valutazione;
drop table if exists prodotti_carrello;
drop table if exists preferito;
drop table if exists categoria;
drop table if exists regione;
drop table if exists traduzioni_categoria;
drop table if exists cantina;
drop table if exists traduzioni_cantina;
drop table if exists vino;
drop table if exists traduzioni_vino;
drop table if exists cesta;
drop table if exists composta_da;
drop table if exists traduzioni_cesta;
drop table if exists caratteristica;
drop table if exists caratteristiche_vino;
drop table if exists indirizzo;
drop table if exists traduzioni_caratteristica;
drop table if exists prodotti_ordine;

create table utente(
	email      	varchar(100)	primary key,
	nome       	varchar(50)    	not null,
	password   	varchar(50) 	not null 
) engine=innodb default charset=latin1;

create table collaboratore(
	email 				varchar(100) 	primary key,
	is_amministratore 	bit 			not null default 0,
	amministratore 		varchar(100)	,
	foreign key (email) 			references utente(email)			on update cascade on delete cascade,
	foreign key (amministratore) 	references collaboratore(email)		on update cascade on delete set null
) engine=innodb default charset=latin1;

create table cliente(
	email 				varchar(100) 	primary key ,
	data_di_nascita 	date 			not null ,
	foreign key (email) references utente(email) on update cascade on delete cascade
) engine=innodb default charset=latin1;

create table indirizzo(
	id 					int 				unsigned auto_increment primary key,
	via 				varchar(50) 		not null,
	stato 				char (2) 			not null default "it",
	provincia 			varchar (20) 		not null,
	n_civico 			varchar (5) 		not null,
	cap 				char(5) 			not null,
	nome_destinatario 	varchar (40) 		not null,
	cliente_email 		varchar(100) 		not null,
	foreign key (cliente_email) references cliente(email) on update cascade on delete cascade
) engine=innodb default charset=latin1;

create table coupon(
	codice 			varchar(20) 	primary key,
	valore 			decimal(6,2) 	unsigned not null default 0,
	cliente_email 	varchar(100) 	,
	foreign key (cliente_email) references cliente(email) on update cascade on delete set null
) engine=innodb default charset=latin1;

create table ordine(
	id 					int 			unsigned auto_increment primary key,
	annullato 			bit 			not null default 0,
	data 				datetime  		not null default now(),
	stato_spedizione 	varchar(100) 	not null default "non impostata",
	codice_tracking 	varchar(100) 	default null,
	link_tracking 		varchar(100) 	default null,
	subtotale 			decimal(7,2) 	unsigned not null default 0,
	cliente_email 		varchar(100) 	not null,
	coupon_codice 		varchar(20) 	unique,
	indirizzo_id 		int 			unsigned not null,
	foreign key (indirizzo_id) 	references indirizzo(id) 	on update cascade on delete cascade,
	foreign key (cliente_email) references cliente(email)	on update cascade on delete cascade,
	foreign key (coupon_codice) references coupon(codice)	on update cascade on delete cascade
) engine=innodb default charset=latin1;

create table dati_fatturazione(
	cliente_email 		varchar(100) 	primary key ,
	partita_iva 		varchar(20)		,
	codice_fiscale 		varchar(20)		,
	pec 				varchar(100) 	not null,
	denominazione 		varchar(100) 	not null,
	codice_fatturazione varchar(30)		,
	cap 				char(5)			not null,
	via 				varchar(100) 	not null,
	paese 				varchar(100) 	not null,
	stato 				char(2) 		not null default "it",
	foreign key (cliente_email) references cliente(email) on update cascade on delete cascade
) engine=innodb default charset=latin1;

create table lingua(
	sigla 		char(2) 		primary key,
	lingua 		varchar(20)		not null
) engine=innodb default charset=latin1;

create table prodotto(
	id 					int 				unsigned auto_increment 	primary key,
	prezzo 				decimal(5,2) 		unsigned not null default 0,
	pezzi_rimanenti 	smallint 			unsigned not null default 0,
	sconto 				decimal(4,2)		unsigned default 0
) engine=innodb default charset=latin1;

create table valutazione(
	cliente_email 	varchar(100) 	not null,
	prodotto_id 	int 			unsigned not null,
	valutazione 	decimal(1,0) 	unsigned not null,
	commento 		varchar(250)	default null,
	data 			timestamp 		not null default current_timestamp,
	primary key(cliente_email, prodotto_id, data),
	foreign key (cliente_email) references cliente(email) 	on update cascade on delete cascade,
	foreign key (prodotto_id) 	references prodotto(id)		on update cascade on delete cascade
) engine=innodb default charset=latin1;

create table prodotti_carrello(
	cliente_email 	varchar(100) 	,
	prodotto_id 	int 			unsigned,
	quantita 		decimal(3,0) 	unsigned default 1,
	primary key(cliente_email, prodotto_id),
	foreign key (cliente_email) references cliente(email) 	on update cascade on delete cascade,
	foreign key (prodotto_id)  	references prodotto(id)		on update cascade on delete cascade
) engine=innodb default charset=latin1;

create table preferito(
	cliente_email 	varchar(100) 	,
	prodotto_id 	int 			unsigned,
	primary key (cliente_email, prodotto_id),
	foreign key (cliente_email) references cliente(email)	on update cascade on delete cascade,
	foreign key (prodotto_id) references prodotto(id)		on update cascade on delete cascade
) engine=innodb default charset=latin1;

create table categoria(
	id 		int 	unsigned auto_increment primary key,
	padre 	int 	unsigned,
	foreign key (padre) references categoria(id)
) engine=innodb default charset=latin1;

create table traduzioni_categoria(
	id 				int 			unsigned,
	lingua 			char(2) 		not null,
	nome 			varchar(35) 	not null,
	descrizione 	varchar(800) 	,
	primary key(id, lingua),
	foreign key (id) 		references categoria(id)	on update cascade on delete cascade,
	foreign key (lingua) 	references lingua(sigla)	on update cascade on delete cascade
) engine=innodb default charset=latin1;

create table regione(
	nome 	varchar(22) 	primary key
) engine=innodb default charset=latin1;

create table cantina(
	sito_internet 	varchar(30) 	primary key,
	telefono 		varchar(20) 	not null,   
	nome 			varchar(30) 	not null,
	regione_nome 	varchar(20)		not null,
	foreign key (regione_nome) references regione(nome)	on update cascade on delete cascade
) engine=innodb default charset=latin1;

create table traduzioni_cantina(
	sito_internet 	varchar(30)		,
	lingua 			char(2)			,
	descrizione 	varchar(400)	not null,
	storia 			varchar(300)	,
	primary key (sito_internet, lingua),
	foreign key (sito_internet) references cantina(sito_internet)	on update cascade on delete cascade,
	foreign key (lingua) 		references lingua(sigla)			on update cascade on delete cascade
) engine=innodb default charset=latin1;

create table prodotti_ordine(
	prodotto_id 	int 			unsigned,
	ordine_id 		int  			unsigned,
	quantita 		decimal(3,0) 	unsigned not null default 1,
	primary key (prodotto_id, ordine_id),
	foreign key (prodotto_id) 		references prodotto(id) 		on update cascade on delete cascade,
	foreign key (ordine_id)  		references ordine(id)			on update cascade on delete cascade
) engine=innodb default charset=latin1;	

create table vino(
	id 						int 			unsigned primary key,
	t_max 					decimal(3,0) 	unsigned not null default 0,
	t_min 					decimal(3,0) 	unsigned not null default 0,
	anno_di_produzione 		decimal(4,0) 	unsigned not null  default 2019,
	tasso_alcolico 			decimal(2,0) 	unsigned not null default 0,
	bio 					bit 			not null default 0,
	categoria_id 			int 			unsigned not null ,
	cantina_sito_internet 	varchar(30) 	not null,
	foreign key (categoria_id) 			references categoria(id) 			on update cascade on delete cascade,
	foreign key (cantina_sito_internet) references cantina(sito_internet)	on update cascade on delete cascade,
	foreign key (id) 					references prodotto(id)				on update cascade on delete cascade
) engine=innodb default charset=latin1;

create table traduzioni_vino(
	id 				int 			unsigned,
	lingua 			char(2)			,
	nome 			varchar(60) 	not null,
	descrizione 	varchar(500) 	not null,
	affinamento 	varchar(50)		default null,
	aroma 			varchar(50) 	not null,
	primary key(id, lingua),
	foreign key (id) 		references vino(id)			on update cascade on delete cascade,
	foreign key (lingua) 	references lingua(sigla)	on update cascade on delete cascade
) engine=innodb default charset=latin1;

create table cesta(
	id 		int 	unsigned primary key,
	foreign key (id) references prodotto(id) on update cascade on delete cascade
) engine=innodb default charset=latin1;

create table composta_da(
	cesta_id 	int 	unsigned,
	vino_id 	int 	unsigned,
	primary key(cesta_id, vino_id),
	foreign key (cesta_id) references cesta(id)	on update cascade on delete cascade,
	foreign key (vino_id)  references vino(id)	on update cascade on delete cascade
) engine=innodb default charset=latin1;

create table traduzioni_cesta(
	id 			int 			unsigned,
	lingua 		char(2) 		,
	nome 		varchar(25) 	not null,
	consiglio 	varchar(200)	default null,
	primary key(id, lingua),
	foreign key (id) 		references cesta(id) 		on update cascade on delete cascade,
	foreign key (lingua) 	references lingua(sigla)	on update cascade on delete cascade
) engine=innodb default charset=latin1;

create table caratteristica(
	id 		int 	unsigned auto_increment primary key,
	tipo 	enum('bottiglia', 'bicchiere', 'abbinamento', 'uva') not null
) engine=innodb default charset=latin1;

create table traduzioni_caratteristica(
	id 		int 		unsigned,
	lingua 	char(2) 	,
	nome 	varchar(30)	not null,
	primary key(id, lingua),
	foreign key (id) 		references caratteristica(id)	on update cascade on delete cascade,
	foreign key (lingua) 	references lingua(sigla)		on update cascade on delete cascade
) engine=innodb default charset=latin1;

create table caratteristiche_vino(
	vino_id 			int 	unsigned,
	caratteristica_id 	int 	unsigned,
	primary key (vino_id, caratteristica_id),
	foreign key (vino_id) 				references vino(id)					on update cascade on delete cascade,
	foreign key (caratteristica_id) 	references caratteristica(id)		on update cascade on delete cascade
) engine=innodb default charset=latin1;

set foreign_key_checks=1;






insert into utente (email, nome, password) values
('capo@itwine.com' , 'Elon Musk' , 'as87d7a8sd'),
('a.sini@itwine.com' , 'Alberto' , 'as987d9as7d'),
('r.sini@itwine.com' , 'Roberta' , 'hf6gfh876'),
('f.bianco@itwine.com' , 'Filippo' , 'k3jh4kh'),
('r.spada@itwine.com' , 'Riccardo' , 'adifuid'),
('giorgia123@gmail.com' , 'Giorgia' , 'e8ruuqrafgida'),
('Luigi.rizzo@libero.it' , 'Luigi Rizzo' , 'e97r87qu'),
('dalpozzo.giorgio08u@mail.com' , 'Dalpozzo Giorgio' , 'wuqyboiu'),
('serena.p99@virgilio' , 'Serena Pagan' , '782463bc7b2389'),
('pasqualepedroletti@mydomain.com' , 'Pasquale' , 'iu32ybc4b3o'),
('alipattaro88@gmail.com' , 'Alice Pattaro' , '98qwyebcunheoq');

insert into collaboratore (email, is_amministratore, amministratore) values
('capo@itwine.com' , b'1' , NULL),
('a.sini@itwine.com' , b'1' , 'capo@itwine.com'),
('r.sini@itwine.com' , b'1' , 'capo@itwine.com'),
('f.bianco@itwine.com' , b'0' , 'r.sini@itwine.com'),
('r.spada@itwine.com' , b'0' , 'r.sini@itwine.com');

insert into cliente (email, data_di_nascita) values
('giorgia123@gmail.com', '1989-1-1'),
('Luigi.rizzo@libero.it', '1967-2-10'),
('dalpozzo.giorgio08u@mail.com' , '1932-2-1'),
('serena.p99@virgilio' , '1945-7-12'),
('pasqualepedroletti@mydomain.com' , '1946-8-17'),
('alipattaro88@gmail.com' , '1999-5-7');

insert into indirizzo (cliente_email, via, stato, provincia, n_civico, cap, nome_destinatario) values
('giorgia123@gmail.com', 			'VIA UMBERTO PRIMO'		, 'IT', 'pd', 23 ,	'23424' , 	'Umberto'),
('giorgia123@gmail.com', 			'via galzignano'		, 'IT', 'br', 545 , 	'74656' , 	'Jamaica'),
('dalpozzo.giorgio08u@mail.com' , 	'via Monticelli'		, 'CA', 'as', 683 , 	'23424' , 	'Luigi'),
('giorgia123@gmail.com' , 			'via Sagredo'			, 'DE', 'cd', 3243 , 	'56436' , 	'Mario'),
('pasqualepedroletti@mydomain.com' ,'Via papa luciano'		, 'UK', 'pt', 32 , 	'23423' , 	'Kevin'),
('alipattaro88@gmail.com' , 		'Via Pasquale terzo'	, 'IT', 've', 498 , 	'46533' , 	'Boris');

insert into coupon (cliente_email, valore, codice) values
('giorgia123@gmail.com', 			   23.2 , 'asd798sa'),
('giorgia123@gmail.com', 			   65 , 'as8udua'),
('dalpozzo.giorgio08u@mail.com' , 	   34 , 's89a7dsa'),
('giorgia123@gmail.com' , 			   67 , 'asjdh89'),
('pasqualepedroletti@mydomain.com' ,   7 , 'asdsaiod'),
('alipattaro88@gmail.com' , 		   12 , 'asd098');

insert into ordine(data, cliente_email, stato_spedizione, link_tracking, codice_tracking, indirizzo_id, coupon_codice, subtotale) values
('2019-1-21 12:56:26', 'giorgia123@gmail.com', 			  "non impostata", 		NULL, NULL,  			1			, 'asd798sa'	, 649.8) ,
('2019-2-5 4:26:14', 'giorgia123@gmail.com', 			  'SPEDITO', 	'rfgrw.com/werrw','n2y3c472cc',  1		, NULL	,45)  ,
('2019-1-2 12:37:37', 'dalpozzo.giorgio08u@mail.com' , 	  'RICEVUTO', 	'rfg4rrsdfrw.com/weasdrrw','fsd876f87s', 3 , NULL, 1605)  ,
('2019-4-16 15:25:14', 'giorgia123@gmail.com' , 			  "non impostata",		NULL,  	NULL,			1		, NULL	, 78)  ,
('2019-12-14 17:38:16', 'pasqualepedroletti@mydomain.com' ,  'SPEDITO' ,	'rfgerefwrw.com/reggr','a87sda87d',  5	, 'asdsaiod', 27 ),  
('2019-6-13 21:48:36', 'giorgia123@gmail.com', 			  'RICEVUTO', 	'ifdbh.com/kjsdfb','asdad423',  2		, 'as8udua'	, 220),  
('2019-8-19 8:37:14', 'giorgia123@gmail.com', 			  'RICEVUTO', 	'aisuhd.com/wesdkfjhrrw','987e9g23', 2 , NULL	, 658)  ,
('2019-6-24 6:25:25', 'dalpozzo.giorgio08u@mail.com' , 	  'RICEVUTO', 	'iudhs.com/asidh', '82d2bjhb3',  	3	, NULL	, 596)  ,
('2019-9-26 9:37:36', 'giorgia123@gmail.com' , 			  'SPEDITO', 	'vkbjn.com/dfiuh', '2hb42hb34j', 	2	, NUll	, 166)  ,
('2019-11-7 12:25:47', 'pasqualepedroletti@mydomain.com' ,  "non impostata", 		NULL,NULL, 					5	 , NULL	,385)  ,
('2019-5-10 9:14:58', 'alipattaro88@gmail.com' ,  "non impostata", 		NULL, NULL, 					6	 , NULL	,136)  ;

insert into dati_fatturazione (cliente_email, partita_iva, codice_fiscale, pec, denominazione, codice_fatturazione, cap, via, paese, stato) values
('giorgia123@gmail.com', 			  'H2B34JV234V', 		'H234KJ23HK234',  'fsgfsd@sdds.com'	, 'giorgia Buffoletto',		'897asd876a', '38947', 'via cingolina', 'Berlino', 'DE') , 
('dalpozzo.giorgio08u@mail.com' , 	  '23HBJ4J3242', 		'2JHB34J234JNB',  'rtrww@wererw.it' , 'Bagigi incorporated',	'asd98as879', '98734', 'via mastrolindo', 'Roma', 'IT')  ,
('pasqualepedroletti@mydomain.com' ,  'SPE2J3HB4JDITO' ,	'KJ2NB34KN234',   'as98d@asda.it'	, 'Batuffaldi spa',			'asd897asd8', '34533', 'via paolo 5', 'Londra', 'UK');

insert into lingua(sigla, lingua) values
('IT', 'ITALIANO'),
('DE', 'DEUTCH'),
('UK', 'ENGLISH');

insert into prodotto(prezzo, pezzi_rimanenti, sconto) values
(34,21,6),
(14,39,8),
(21,30,9),
(81,38,3),
(6,2,4),
(6,44,5),
(78,44,9),
(16,16,8),
(57,57,8),
(79,88,7),
(32,87,5),
(31,56,1),
(14,30,8),
(46,18,1),
(55,95,9),
(68,37,2),
(93,46,1),
(95,97,2),
(8,19,5),
(94,67,4);

insert into valutazione(cliente_email, prodotto_id, valutazione, commento, data) values
('giorgia123@gmail.com', 		1	  	 , 3 , 'schifo', 		'2019-12-18'),
('dalpozzo.giorgio08u@mail.com' , 	1	 , 6 , 'discreto', 		'2019-6-28'),
('giorgia123@gmail.com', 			1  	 , 9 , 'piacevole', 	'2019-3-31'),
('dalpozzo.giorgio08u@mail.com' , 	2	 , 7 , 'buono', 		'2019-7-3'),
('giorgia123@gmail.com', 			2  	 , 2 , 'fa pietà', 		'2019-9-5'),
('giorgia123@gmail.com', 			3  	 , 1 , 'non mi piace', 	'2019-9-5'),
('dalpozzo.giorgio08u@mail.com' , 	4	 , 6 , 'discreto dai', 	'2019-4-18'),
('pasqualepedroletti@mydomain.com' , 5	 , 9 , NULL, 			'2019-11-16'),
('dalpozzo.giorgio08u@mail.com' , 	1	 , 2 , 'pessimo', 		'2019-5-20'),
('pasqualepedroletti@mydomain.com' , 4	 , 6 , NULL, 			'2019-9-12');

insert into prodotti_ordine(prodotto_id, ordine_id,quantita) values
(5,2,4),
(1,7,3),
(2,1,1),
(3,3,7),
(8,6,6),
(14,7,1),
(17,3,7),
(8,9,7),
(12,3,8),
(2,3,1),
(9,8,4),
(6,9,5),
(8,3,2),
(1,5,1),
(1,3,7),
(15,7,8),
(13,7,5),
(11,1,8),
(2,4,1),
(10,6,2),
(12,6,1),
(15,3,5),
(5,9,4),
(14,8,8),
(8,4,4),
(6,1,3),
(15,1,7),
(15,10,7),
(16,11,2),
(3,2,1);

insert into prodotti_carrello(cliente_email, prodotto_id,quantita) values
('giorgia123@gmail.com',6,7),
('serena.p99@virgilio',9,5),
('pasqualepedroletti@mydomain.com',6,1),
('Luigi.rizzo@libero.it',2,10),
('giorgia123@gmail.com',1,10),
('Luigi.rizzo@libero.it',8,16),
('pasqualepedroletti@mydomain.com',9,10),
('Luigi.rizzo@libero.it',9,2),
('giorgia123@gmail.com',9,0),
('serena.p99@virgilio',5,2),
('pasqualepedroletti@mydomain.com',1,16),
('serena.p99@virgilio',7,7),
('dalpozzo.giorgio08u@mail.com',7,12),
('Luigi.rizzo@libero.it',4,9),
('giorgia123@gmail.com',8,1),
('dalpozzo.giorgio08u@mail.com',4,5),
('serena.p99@virgilio',4,18),
('dalpozzo.giorgio08u@mail.com',5,10),
('Luigi.rizzo@libero.it',1,7),
('dalpozzo.giorgio08u@mail.com',9,13),
('serena.p99@virgilio',8,5),
('Luigi.rizzo@libero.it',7,6);

insert into categoria(padre)values
(NULL),
(NULL),
(1),
(2),
(3);

insert into traduzioni_categoria(id, lingua, nome, descrizione)values
(1 ,'IT', 'VINI ROSSI', 'Il vino rosso rientra tra i cosiddetti piaceri della tavola, indicato per accompagnare i momenti di convivialità, apprezzato per i suoi profumi e le gioie che riserva al palato.'),
(1 ,'UK', 'RED WINES', 'Red wine is one of the so-called pleasures of the table, indicated to accompany moments of conviviality, appreciated for its aromas and the joys it reserves for the palate.'),
(1 ,'DE', 'ROTWEIS', 'Rotwein ist ein sogenanntes Tafelvergnügen, das Momente der Geselligkeit begleitet und für seine Aromen und Freuden für den Gaumen geschätzt wird.'),
(2 ,'IT', 'VINI BIANCHI', 'Come aperitivo e soprattutto abbinato ad un piatto di pesce il vino bianco è sicuramente un must, ma non è facile percepire quale delle tante etichette sarà la più adatta alla circostanza. '),
(2 ,'UK', 'WHITE WINES', 'As an aperitif and especially paired with a fish dish, white wine is certainly a must, but it is not easy to perceive which of the many labels will be the most suitable for the occasion.'),
(3 ,'IT', 'ROSSO TOSCANO', NULL),
(4 ,'IT', 'VINO BIANCO DEL NORD ITALIA', NULL),
(5 ,'IT', 'VINO ROSSO TOSCANO PLURIPREMIATO', NULL);

insert into regione values
('Marche'),
('Abruzzo'),
('Basilicata'),
('Molise'),
('Trentino Alto Adige'),
('Puglia'),
('Calabria'),
('Campania'),
('Lazio'),
('Sardegna'),
('Sicilia'),
('Toscana'),
('Piemonte'),
('Emilia Romagna'),
('Friuli Venezia Giulia'),
('Valle d\'Aosta'),
('Veneto'),
('Liguria'),
('Lombardia'),
('Umbria');

insert into cantina(sito_internet, telefono, nome, regione_nome)values 
('cantinarosso.com', '9283487', 'Cantina Rosso', 'Marche'),
('miovino.com', '238498273', 'Mio Vino SRL', 'Abruzzo'),
('vivino.it', '29387423', 'ViVino', 'Veneto'),
('salamso.com', '8542892', 'Salmaso', 'Abruzzo'),
('menato.vini.com', '2349892', 'Menato Vini', 'Toscana'),
('ducadisaragnano.it', '2309824', 'Duca di Saragnano', 'Liguria'),
('allegrini.it', '232342344', 'La Allegrini', 'Sicilia'),
('cantina75.com', '902803432840', 'Cantina 75', 'Molise');

insert into traduzioni_cantina(sito_internet, lingua, descrizione, storia)values 
('cantinarosso.com', 'IT', 'Un nuovo singolare progetto, nato dalla “pazza” idea di due giovani appassionati di vino, desiderosi di trasmettere il loro amore per queste zone. “Ci siamo quindi immersi in questa avventura, dal nome Cà de Pazzi, inspirandoci (lo ammettiamo) anche al celebre ed immortale film di Totò del 1939', NULL),
('cantinarosso.com', 'UK', 'A new singular project, born from the "crazy" idea of two young wine lovers, eager to convey their love for these areas. “We then immersed ourselves in this adventure, named Cà de Pazzi, inspiring (we admit it) also the famous and immortal film by Totò of 1939', NULL),
('cantinarosso.com', 'DE', 'Ein neues einzigartiges Projekt, geboren aus der "verrückten" Idee zweier junger Weinliebhaber, die ihre Liebe für diese Gebiete zum Ausdruck bringen wollen. „Wir haben uns dann auf dieses Abenteuer mit dem Namen Cà de Pazzi eingelassen und damit auch den berühmten und unsterblichen Film von Totò aus dem Jahr 1939 inspiriert (wir geben es zu)', NULL),
('miovino.com', 'IT', 'è il brand più importante dell\'azienda Barbanera, alla quale ne è stato concesso l\'utilizzo, per gentile concessione di un discendente del Signore di Saragnano, grande amico del patron Luigi Barbanera. Tre passaggi fondamentali segnano la vita di questa azienda: 1938', 'Abruzzo'),
('vivino.it', 'IT', 'In uno scenario magico sulle colline Irpine, nel cuore di Paternopoli (Avellino), nasce nel 2008 l\'azienda agricola Nativ. Il nome la dice lunga sull\'impronta che il proprietario enologo Mario Ercolino e la moglie Maria Roberta Pirone intendono dare all\'azienda', ' Un po\' di romanticismo, di pop e di follia! Iniziamo con la personificazione di un rinoceronte e una giraffa ed arriviamo alla bollicina più genuina ed affascinante'),
('salamso.com', 'IT', 'Tali eremiti venivano definiti all’epoca come “Pater” e il nome storico “Paternopoli” venne anticamente scelto proprio per indicare quel luogo così pacifico e soave scelto da questi padri eremiti', 'nasce in un luogo idilliaco dalla lunghissima storia. Nel territorio Irpino di Paternopoli, la vite veniva già coltivata nel IV sec. a.C'),
('menato.vini.com', 'IT', 'Tutto è nato da un’idea dell’avvocato milanese Giancarlo Cignozzi, già ampiamente noto, nel panorama vitivinicolo toscano, poiché fondatore della rinomata tenuta di Caparzo, a Montalcino', 'Una cantina giovane ma artigianale, nata nel 2000, innovativa per il suo particolare obiettivo di caratterizzare e migliorare i propri vini, in cantina e in vigna, grazie all’impiego della musicoterapia'),
('menato.vini.com', 'UK', 'Everything was born from an idea of Milanese lawyer Giancarlo Cignozzi, already widely known, in the Tuscan wine scene, as founder of the renowned Caparzo estate, in Montalcino', 'A young but artisan winery, founded in 2000, innovative for its particular purpose of characterizing and improving its wines, in the cellar and in the vineyard, thanks to the use of music therapy'),
('menato.vini.com', 'DE', 'Alles ist auf die Idee des Mailänder Anwalts Giancarlo Cignozzi zurückzuführen, der in der toskanischen Weinszene als Begründer des renommierten Weinguts Caparzo in Montalcino bereits weithin bekannt war', 'Ein junges, aber handwerkliches Weingut, das im Jahr 2000 gegründet wurde. Es wurde speziell für die Charakterisierung und Verbesserung seiner Weine im Keller und im Weinberg mithilfe von Musiktherapie entwickelt'),
('ducadisaragnano.it', 'IT', 'Duca di Saragnano è il brand più importante dell\'azienda Barbanera, alla quale ne è stato concesso l\'utilizzo, per gentile concessione di un discendente del Signore di Saragnano, grande amico del patron Luigi Barbanera. Tre passaggi fondamentali segnano la vita di questa azienda', ' l\'attività famigliare che nel 1978 vede la nascita della Enogest per opera di Marco e Paolo'),
('allegrini.it', 'IT', 'Era il 1989 quando la “leggendaria” famiglia Allegrini in collaborazione con un gruppo selezionatissimo di fedeli collaboratori decidono di imbastire un nuovo progetto per la valorizzazione del territorio', 'Con estrema puntualità sono nati vini che rispecchiano fedelmente il territorio e che riscontrano in pieno i gusti dei consumatori , sempre più attenti e ricercati.'),
('cantina75.com', 'IT', 'nasce dalla voglia di un gruppo di professionisti di lanciare sul mercato un serie di vini di qualità ad un prezzo accessibile, perché bere bene è un diritto di tutti', 'Un modello aziendale con un taglio moderno e giovanile, ma che non ha rinunciato ai valori e le tradizioni nel rispetto del territorio. Cultura nel bere e piacevolezza di beva, molto piu\' di due semplici concetti!!');

insert into vino(id, cantina_sito_internet, t_min, t_max, anno_di_produzione, tasso_alcolico, bio, categoria_id) values
(1 , 'cantinarosso.com', 20,22,2008,13,b'0',1),
(2 , 'cantinarosso.com', 22,25,2002,14,b'0', 3),
(3 , 'cantinarosso.com', 26,28,2002,14,b'1', 4),
(4 , 'cantinarosso.com', 29,33,2008,14,b'0',5),
(5 , 'vivino.it', 26,31,2002,11,b'0',2),
(6 , 'miovino.com', 27,34,2002,10,b'0',1),
(7 , 'salamso.com', 29,36,2006,14,b'0',4),
(8 , 'salamso.com', 27,30,2006,13,b'1',1),
(9 , 'salamso.com', 24,32,2002,12,b'0',2),
(10 , 'menato.vini.com', 22,30,2003,13,b'0',5),
(11 , 'menato.vini.com', 24,29,2001,12,b'1',2),
(12 , 'ducadisaragnano.it', 29,35,2004,12,b'0',2),
(13 , 'allegrini.it', 29,31,2006,13,b'0',4),
(14 , 'allegrini.it', 22,25,2008,14,b'1',2),
(15 , 'cantina75.com', 24,28,2005,14,b'0',5);

insert into traduzioni_vino (id, lingua, nome, descrizione, affinamento, aroma) values
(1 ,  'IT', 'Bolgheri Superiore DOC 2014 Grattamacco', 'Questo Bolgheri Rosso Superiore nasce nella tenuta di Grattamacco, situata sulla sommità di una collina che si affaccia sul mare tra Castagneto Carducci e Bolgheri.', 'Barrique', 'Fruttato'),
(1 ,  'DE', 'Bolgheri Superiore DOC 2014 Grattamacco', 'Dieser Bolgheri Rosso Superiore wurde auf dem Landgut Grattamacco auf einem Hügel zwischen Castagneto Carducci und Bolgheri mit Blick auf das Meer geboren.', 'Barrique', 'Fruchtig'),
(1 ,  'UK', 'Bolgheri Superiore DOC 2014 Grattamacco', 'This Bolgheri Rosso Superiore was born in the Grattamacco estate, located on the top of a hill overlooking the sea between Castagneto Carducci and Bolgheri.', 'Barrique', 'Fruity'),
(2 ,  'IT', 'Brunello di Montalcino DOCG', 'Il Brunello di Montalcino di Villa da Filicaja trae origine da vigneti localizzati sul versante sud-ovest del comune di Montalcino.', 'Botte di rovere di Slavonia', 'Fruttato'),
(2 ,  'DE', 'Brunello der Montalcino DOCG', 'Brunello di Montalcino of Villa da Filicaja originates from vineyards located on the southwest side of the municipality of Montalcino.', 'Slawonisches Eichenfass', 'Fruchtig'),
(3 ,  'IT', 'Emilia IGT Otello Nero di Lambrusco', 'Otello Nero nasce in provincia di Parma, nel cuore della terra del Lambrusco. La vendemmia si svolge verso l’inizio di ottobre. Le uve subiscono un processo di macerazione a freddo a bassa temperatura per 5-7 giorni,', 'acciaio inox,', 'Fruttato'),
(4 ,  'IT', 'Amarone della Valpolicella DOCG ', 'L\'Amarone della Valpolicella Dal Moro nasce a Negrar, nel cuore della Valpolicella, da vigneti posti a un\'altitudine di 150-450 metri sul livello del mare.', 'Botte di legno', 'Amarena'),
(5 ,  'IT', 'Südtirol - Alto Adige DOC', 'Il Sauvignon di Blumenfeld è un vino che prende origine dalle colline che circondano il comune di Bolzano.', 'Acciaio', 'Vegetale'),
(5 ,  'UK', 'Südtirol - Alto Adige DOC', 'Sauvignon di Blumenfeld is a wine that originates from the hills surrounding the municipality of Bolzano.', 'Steel', 'Vegetable'),
(6 ,  'IT', 'Sicilia Grillo DOC 2018 Li Ciuri', 'Un tripudio di colori che si esaltano in un mosaico variopinto, “Li Ciuri”, i fiori, nel dialetto siciliano, rappresenta un omaggio al terroir di provenienza', 'Vasca di cemento', 'Gelsomino'),
(7 ,  'IT', 'Friuli Isonzo DOC Bianco Flors di Uis 2017 Vie di Romans', 'Il Friuli Isonzo Bianco Flors di Uis dell\'azienda Vie di Romans nasce nei vigneti Boghis, Ciampagnis e Vie di Romans', null, 'Arancia'),
(8 ,  'IT', 'Venezia Giulia Bianco IGT Vintage Tunina 2017 Jermann', 'Il Venezia Giulia Bianco Vintage Tunina di Jermann nasce in vigneti situati a Villanova di Farra, nel cuore del Friuli', null, 'Miele'),
(9 ,  'IT', 'Franciacorta Brut DOCG Alma Gran Cuvée Bellavista', 'Lo spumante Franciacorta Alma Gran Cuvée Brut di Bellavista nasce in vigneti situati nel cuore della DOCG Franciacorta', 'Barrique di rovere', 'Vaniglia'),
(10 , 'IT', 'Franciacorta Pas Dosé DOCG', 'Un Franciacorta unico e inimitabile, che nel nome e nell’etichetta richiama la notte stellata, ideale per accompagnare piacevolmente le tue serate e addolcire i tuoi sogni', '30 mesi sui lieviti', 'Fiori'),
(11 , 'IT', 'Franciacorta Brut DOCG Corte alle Stelle', 'Il riverbero del lago di Iseo si rispecchia nella classe innata di questa bollicina. ', '18 mesi sui lieviti', 'Crema'),
(11 , 'UK', 'Franciacorta Brut DOCG Corte alle Stelle', 'The reverberation of Lake Iseo is reflected in the innate class of this bubble.', '18 months on the lees', 'Cream'),
(12 , 'IT', 'Whisky From the Barrel Nikka', 'Il Whisky From the Barrel di Nikka è un blended whisky ottenuto dalla miscela di whisky single malt e grain whisky giapponesi', null, 'Fruttato'),
(13 , 'IT', 'Barolo Sottocastello di Novello', 'Barolo proveniente dal pregiato cru Sottocastello di Novello, esposto a sud-sud est', 'Botte di rovere', 'Cannella'),
(14 , 'IT', 'Amarone della Valpolicella DOCG', 'Questo Amarone prende vita dai vigneti siti a nord di Verona, nella zona di produzione della Valpolicella.', 'Botte di rovere', 'Caffè'),
(15 , 'IT', 'Nizza DOCG La Luna', 'Vino rosso che prende vita dai suoli calcarei e aridi della Nizza DOCG.', 'Barrique', 'Caramello');

insert into cesta values
(16),
(17),
(18),
(19),
(20);

insert into composta_da(vino_id, cesta_id) values
(10,18),
(11,20),
(8,17),
(3,16),
(11,18),
(7,19),
(7,16),
(8,18),
(15,18),
(14,16),
(9,19),
(5,18),
(3,17),
(8,16),
(9,18);

insert into traduzioni_cesta (id, lingua, nome, consiglio) values
(16, 'IT', 'Cesta Natale 2018', 'Ottima come regalo di natale a colleghi e parenti, oppure per cenoni come coronamento della serata'),
(16, 'UK', 'Christmas basket 2018', 'Excellent as a Christmas present to colleagues and relatives, or for dinners as a crowning event'),
(16, 'DE', 'Weihnachtskorb 2018', 'Hervorragend als Weihnachtsgeschenk für Kollegen und Verwandte oder zum Abendessen als Krönung'),
(17, 'IT', 'San Valentino 2018', 'Mai più San Valentino senza un po di buon vino rosso, approfittane finchè c\è tempo'),
(18, 'IT', 'Cesta Estate 2018', 'Finalmente è arrivata l\'estate! Passala accompagnato da una buona cesta di vino bianco con del buon pesce'),
(18, 'UK', 'Summer Basket 2018', 'Summer has finally arrived! Pass it accompanied by a good basket of white wine with good fish'),
(19, 'IT', 'Cesta Natale 2019', 'Non se ne può più del solito regalo riciclato, quest\'anno approfittane di questa cesta per rendere felici tutti'),
(20, 'IT', 'Estate 2019', 'L\'estate è arrivata finalmente, e non c\' niente meglio di una buona bottiglia di vino con la persona giusta'),
(20, 'UK', 'Summer 2019', 'Summer has finally arrived, and there is nothing better than a good bottle of wine with the right person'),
(20, 'DE', 'Sommer 2019', 'Der Sommer ist endlich da und es gibt nichts Schöneres als eine gute Flasche Wein mit der richtigen Person');

insert into caratteristica(tipo) values
('bicchiere'),
('abbinamento'),
('bicchiere'),
('bottiglia'),
('bicchiere'),
('bottiglia'),
('abbinamento'),
('uva');

insert into caratteristiche_vino (vino_id, caratteristica_id) values
(8,7),
(5,1),
(9,2),
(11,3),
(3,1),
(10,8),
(9,7),
(4,2),
(7,2),
(2,1),
(12,3),
(8,6),
(4,4),
(14,2),
(1,7);

insert into traduzioni_caratteristica(id, lingua, nome) values
(1, 'IT', 'bicchiere flut'),
(2, 'IT', 'pasta'),
(3, 'IT', 'bicchiere copitaopita'),
(4, 'IT', 'bottiglia da 75cl'),
(4, 'UK', '75cl bottle'),
(4, 'DE', '75cl Flasche'),
(5, 'IT', 'Coppa asti'),
(6, 'IT', 'bottiglia ad Anfora'),
(6, 'UK', 'Amphora bottle'),
(7, 'IT', 'pollo'),
(8, 'IT', 'uva essiccata al sole');

insert into preferito(cliente_email, prodotto_id) values 
('serena.p99@virgilio', 8),
('Luigi.rizzo@libero.it', 4),
('serena.p99@virgilio', 16),
('pasqualepedroletti@mydomain.com', 3),
('pasqualepedroletti@mydomain.com', 18),
('serena.p99@virgilio', 9),
('alipattaro88@gmail.com', 11),
('giorgia123@gmail.com', 5),
('pasqualepedroletti@mydomain.com', 14),
('dalpozzo.giorgio08u@mail.com', 2),
('serena.p99@virgilio', 2),
('alipattaro88@gmail.com', 7),
('serena.p99@virgilio', 6),
('dalpozzo.giorgio08u@mail.com', 8),
('giorgia123@gmail.com', 6),
('serena.p99@virgilio', 13),
('pasqualepedroletti@mydomain.com', 5),
('pasqualepedroletti@mydomain.com', 2),
('pasqualepedroletti@mydomain.com', 16),
('giorgia123@gmail.com', 15),
('dalpozzo.giorgio08u@mail.com', 18),
('Luigi.rizzo@libero.it', 6),
('giorgia123@gmail.com', 14),
('pasqualepedroletti@mydomain.com', 8),
('serena.p99@virgilio', 15),
('serena.p99@virgilio', 17),
('dalpozzo.giorgio08u@mail.com', 12),
('alipattaro88@gmail.com', 10),
('pasqualepedroletti@mydomain.com', 17);

/*
	indice per la ricerca nei vini di una parola chiave
*/
drop index if exists fulltext_per_ricerche_su_vino on traduzioni_vino;
create fulltext index fulltext_per_ricerche_su_vino on traduzioni_vino(nome, descrizione, aroma, affinamento);
/* query per la ricerca, ottimizzata tramite indici con parola chiave */
select * from traduzioni_vino where match (nome, descrizione, aroma, affinamento ) against ('barolo');



/*
	indice per la creazione di report per ogni utente in uno specifico periodo
*/
drop index if exists report_ordini_per_utente_in_un_periodo on ordine;
create index report_ordini_per_utente_in_un_periodo on ordine(data, cliente_email, subtotale);
/* Query per verifica corretto utilizzo dell'indice */
explain select cliente_email from ordine where data between '2020-01-01 00:00:00' and '2020-12-31 23:59:59' group by cliente_email;




/*
	per ogni utente elencare i prodotti acquistati, con il totale della quantità acquistata 
	e il numero volte che è stato acquistato (si crea un vista con esso per poterlo 
	riutilizzare in query successive) 
*/
drop view if exists prodotto_volte_quantita_acquistata;
create view prodotto_volte_quantita_acquistata as
select cliente_email CLIENTE, prodotto_id PRODOTTO , SUM(quantita) QUANTITA, COUNT(*) VOLTE_ACQUISTATO 
from prodotti_ordine join ordine on ordine.id = prodotti_ordine.ordine_id
group by cliente_email, prodotto_id 
order by COUNT(*) desc;
select * from prodotto_volte_quantita_acquistata;


/* 
	trovare i 5 prodotti più probabili che un utente acquisti, 
	basandosi sui suoi preferiti, i suoi prodotti acquistati in precedenza, 
	le sue valutazioni e i prodotti nel carrello
*/
set @cliente_email := "giorgia123@gmail.com";
select PRODOTTO, sum(QUANTITA) PROBABILITA from (
		select p.cliente_email CLIENTE_EMAIL, p.prodotto_id PRODOTTO, cast(5 as DOUBLE) QUANTITA 
		from preferito p 
	union
		select v.cliente_email, v.prodotto_id, 
			case when AVG(v.valutazione) < 5 then (-1* count(*)*AVG(v.valutazione)) 
			else (count(*)*AVG(v.valutazione)) 
		end 
		from valutazione v 
		group by v.prodotto_id, v.cliente_email
	union 
		select c.cliente_email, c.prodotto_id, c.quantita*2 
		from prodotti_carrello c
	union 
		select CLIENTE, PRODOTTO, QUANTITA 
		from prodotto_volte_quantita_acquistata
) tmp
where CLIENTE_EMAIL= @cliente_email
group by PRODOTTO
order by sum(QUANTITA) desc
limit 5;



/*
	per ogni cantina mostrare il numero dei vini di cui non ne sono stati venduti più di 2 bottiglie nello stesso ordine
*/
select nome NOME, sito_internet SITO_INTERNET, count(cantina_sito_internet) NUMERO_VINI_VENDUTI_2_BOTTIGLIE_STESSO_ORDINE
from cantina left join (
	select cantina_sito_internet
	from vino
	where exists (
		select prodotto_id
		from prodotti_ordine
		where quantita<2 and prodotto_id = vino.id
	)
)tmp on cantina_sito_internet=sito_internet
group by sito_internet, nome;



/*
	visualizzare i 3 utenti con la maggiore propensione all'acquisto di vini povenienti da regioni che iniziano per M
*/
select 
	email CLIENTE_EMAIL, 
	coalesce(numero_vini_acquistati_da_regioni_senza_M, 0) NUMERO_VINI_DA_REGIONI_SENZA_M, 
	coalesce(numero_vini_acquistati_da_regioni_con_M, 0) NUMERO_VINI_DA_REGIONI_CON_M,
	coalesce(numero_vini_acquistati_da_regioni_senza_M, 0) / coalesce(numero_vini_acquistati_da_regioni_con_M, 0) RAPPORTO
from cliente left join(
	select email email_regioni_senza_M, avg(prodotti_ordine.quantita) numero_vini_acquistati_da_regioni_senza_M 
	from cliente join ordine on email = cliente_email 
				join prodotti_ordine on id = ordine_id 
				join(
                    select id 
                    from (vino join cantina on cantina_sito_internet = sito_internet) where regione_nome not like "M%"
                ) tmp on prodotto_id = tmp.id
	group by email
)regioni_senza_m on email = email_regioni_senza_M left join (
	select email email_regioni_con_M, avg(prodotti_ordine.quantita)  numero_vini_acquistati_da_regioni_con_M 
	from cliente join ordine on email = cliente_email 
				join prodotti_ordine on id = ordine_id 
				join(
                    select id 
                    from (vino join cantina on cantina_sito_internet = sito_internet) where regione_nome like "M%"
                ) tmp on prodotto_id = tmp.id
	group by email
) regioni_con_M on email = email_regioni_con_M
where coalesce(numero_vini_acquistati_da_regioni_senza_M, 0) < coalesce(numero_vini_acquistati_da_regioni_con_M, 0)
order by coalesce(numero_vini_acquistati_da_regioni_senza_M, 0) / coalesce(numero_vini_acquistati_da_regioni_con_M, 0) asc
limit 3;



/* 
	visualizzare l'Id, l'email dell'acquirente, e la data degli ordini in cui son state acquistate solo ceste con al loro interno più di 2 vini (diversi)
*/
select id ID_ORDINE , data DATA_ORDINE, cliente_email EMAIL_CLIENTE
from ordine
where exists(
	select * from prodotti_ordine join(
		select id
		from cesta join composta_da on cesta_id = id
		group by id
		having count(*)>2
	) tmp on id= prodotto_id
	where ordine_id = ordine.id
)
and not exists(
	select distinct ordine_id from prodotti_ordine join vino on prodotto_id = id where ordine_id = ordine.id
);



/* 
	mostrare per ogni mese (in cui c'è stato almeno un ordine), il numero di ordini contententi vini con una caratteristica appartenente alla categoria 
	fornita con all'interno del nome la stringa fornita
*/

set @tipologia_caratteristica := "bicchiere";
set @stringa_da_trovare := "flut";
select concat(month(data), " / ", year(data)) as MESE, count(*) AS TOTALE_ORDINI
from ordine join prodotti_ordine on id = ordine_id
where prodotto_id in(
	select distinct vino_id 
	from caratteristiche_vino
	where exists(
	 	select traduzioni_caratteristica.id 
	 	from traduzioni_caratteristica join caratteristica on caratteristica.id = traduzioni_caratteristica.id and tipo = @tipologia_caratteristica
	 	where nome like concat("%",@stringa_da_trovare,"%") and caratteristiche_vino.caratteristica_id = traduzioni_caratteristica.id 
	)
	union
	select distinct cesta_id
	from composta_da 
	where exists(
		select vino_id 
		from caratteristiche_vino
		where exists(
		 	select traduzioni_caratteristica.id 
		 	from traduzioni_caratteristica join caratteristica on caratteristica.id = traduzioni_caratteristica.id and tipo = @tipologia_caratteristica
		 	where nome like concat("%",@stringa_da_trovare,"%") and caratteristiche_vino.caratteristica_id = traduzioni_caratteristica.id 
		) and vino_id = composta_da.vino_id
	)
)
group by year(data) asc , month(data) asc;




/*
	trigger per il check che la quantità disponibile per un prodotto sia sempre minore o uguale a quella richiesta da un nuovo ordine
*/
drop trigger if exists quantita_richiesta_minore_della_quantita_rimanente;
DELIMITER || 
create trigger quantita_richiesta_minore_della_quantita_rimanente
before insert on prodotti_ordine 
for each row 
begin
  	declare qnt int;
  	select pezzi_rimanenti into qnt from prodotto where id = new.prodotto_id; 
  	if (new.quantita > qnt) then signal sqlstate '45000' set message_text = "quantità richiesta maggiore di quella disponibile.";
    else update prodotto set pezzi_rimanenti = pezzi_rimanenti - new.quantita where id = new.prodotto_id;
  	end if; 
end ||
DELIMITER ;



commit;

































