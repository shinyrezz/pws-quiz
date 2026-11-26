
extends RefCounted

const QUESTIONS := [
	{
		"ch": "De start",
		"q": "Je hebt net een nieuw bedrijf opgericht met alleen jij en 2 vrienden. Hoe ga je het beveiligen?",
		"o": [
			"Nog niet. Hackers richten zich op grote bedrijven, dus ik steek mijn tijd liever in klanten zoeken.",
			"Ik spreek met mijn vrienden af dat we goed opletten bij rare mails. Dat kost niks en we kennen elkaar goed.",
			"We nemen allemaal een sterk wachtwoord en installeren een virusscanner. Dat is snel geregeld.",
			"We zetten overal tweestapsverificatie aan en bouwen alles vanaf het begin veilig op. Dat kost nu wat tijd, maar later hoeven we niks om te bouwen.",
		],
	},
	{
		"ch": "De eerste klanten",
		"q": "Je bedrijf krijgt de eerste klanten. Waar bewaar je hun gegevens?",
		"o": [
			"In een Excel-bestand op de gedeelde computer. Iedereen kan er snel bij en het is gratis.",
			"In een gedeelde cloudmap met één wachtwoord voor ons drieën. Makkelijk, en we kunnen overal bij.",
			"In een klantsysteem waarin we alle drie een eigen account hebben. Dan zie je wie wat heeft aangepast.",
			"In een beveiligd systeem waarin we alleen opslaan wat we echt nodig hebben. Minder gegevens betekent minder om kwijt te raken.",
		],
	},
	{
		"ch": "De website",
		"q": "Je laat een website maken. Een paar maanden later komt het nieuws over PHP2Shell, een ernstig lek in de software van ongeveer 70% van alle websites. Wat doe je?",
		"o": [
			"Ik laat de website gewoon online. Elk uur offline kost omzet, en er zijn duizenden andere websites die ze eerst aanvallen.",
			"Ik zet het op de lijst voor de websitebouwer. Hij komt volgende maand toch al langs, dat scheelt een extra rekening.",
			"Ik laat de update deze week installeren. Dan kan de bouwer het netjes testen zonder haast.",
			"Ik haal de website meteen offline tot het lek gedicht is, en ik zet automatische updates aan. Een paar uur offline is goedkoper dan een hack.",
		],
	},
	{
		"ch": "Het eerste personeel",
		"q": "Je neemt je eerste 5 medewerkers aan. Hoe regel je hun accounts?",
		"o": [
			"Iedereen gebruikt het bedrijfsaccount. Extra accounts kosten licentiegeld per persoon.",
			"Iedereen krijgt een eigen account en kiest zelf een wachtwoord. Dat onthouden ze het makkelijkst.",
			"Eigen accounts met verplicht sterke wachtwoorden. Dat is een kleine moeite.",
			"Eigen accounts met tweestapsverificatie, en iedereen kan alleen bij wat hij voor zijn werk nodig heeft. Dat kost wat meer tijd om in te stellen.",
		],
	},
	{
		"ch": "De eerste phishingmails",
		"q": "Er komen steeds meer phishingmails binnen. Hoe bereid je je medewerkers voor?",
		"o": [
			"Niet. De spamfilter van ons mailprogramma houdt de meeste tegen, dus het is zonde van hun werktijd.",
			"Ik stuur iedereen één keer een mail met tips om phishing te herkennen. Dat kost vijf minuten.",
			"Iedereen volgt één keer per jaar een online training. Dan is het in één keer geregeld.",
			"Regelmatig korte trainingen, en af en toe stuur ik zelf een nep-phishingmail om te testen wie erin trapt. Dat kost steeds een beetje tijd.",
		],
	},
	{
		"ch": "Updates",
		"q": "Medewerkers krijgen steeds meldingen dat hun laptop een update moet installeren. Wat regel je?",
		"o": [
			"Ze mogen de updates overslaan. Een herstart midden op de dag kost werktijd.",
			"Ze installeren de updates wanneer het hun uitkomt. Zij weten zelf het best wanneer ze tijd hebben.",
			"Eén keer per maand doet iedereen tegelijk de updates. Dan kun je het goed plannen.",
			"De updates worden automatisch 's nachts geïnstalleerd. Dat moet één keer ingesteld worden.",
		],
	},
	{
		"ch": "Back-ups",
		"q": "Hoe maak je back-ups van je bedrijfsgegevens?",
		"o": [
			"We maken geen aparte back-ups. Alles staat al in de cloud, en dat is al veilig.",
			"Eén keer per week zet iemand de belangrijkste bestanden op een externe harde schijf. Goedkoop en simpel.",
			"Er wordt elke dag automatisch een back-up gemaakt in de cloud. Daar hoef je niet meer aan te denken.",
			"Elke dag een automatische back-up, ook een kopie die los van het netwerk staat, en we testen of terugzetten werkt. Dat kost wat extra opslag en tijd.",
		],
	},
	{
		"ch": "De groei",
		"q": "Je bedrijf groeit naar 40 medewerkers met laptops, telefoons, printers en servers. Hoe houd je bij wat je allemaal hebt?",
		"o": [
			"Dat houd ik niet bij. Als iets kapot is, merken we het vanzelf.",
			"Ik weet het grotendeels uit mijn hoofd. Ik heb bijna alles zelf gekocht.",
			"Er is een Excel-lijst die we bijwerken als we eraan denken.",
			"We gebruiken een programma dat automatisch bijhoudt welke apparaten er op het netwerk zitten. Dat kost een abonnement.",
		],
	},
	{
		"ch": "De boekhouder",
		"q": "Je besteedt de boekhouding uit aan een ander bedrijf. Wat doe je aan hun beveiliging?",
		"o": [
			"Niks. Ik heb ze ingehuurd zodat ik me er niet mee bezig hoef te houden.",
			"Ik heb voor een bekend en groot kantoor gekozen. Die hebben hun beveiliging vast op orde.",
			"Ik zet afspraken over beveiliging in het contract. Dan zijn zij verantwoordelijk als het misgaat.",
			"Ik stel eisen, controleer die regelmatig en geef ze alleen toegang tot wat ze nodig hebben. Dat kost tijd, en het contract wordt duurder.",
		],
	},
	{
		"ch": "De investeerder",
		"q": "Een investeerder vraagt hoeveel geld je aan cybersecurity wilt uitgeven. Wat zeg je?",
		"o": [
			"Zo min mogelijk. Dat geld kan beter naar groei en marketing.",
			"Niet veel extra. We gebruiken Microsoft 365, en daar zit beveiliging al in.",
			"Een vast budget voor goede beveiligingssoftware. Dan weet je precies wat het kost.",
			"Budget voor de basis, en tijd om het personeel te trainen. Dat is duurder, want ze werken die uren niet.",
		],
	},
	{
		"ch": "AI op de werkvloer",
		"q": "Je medewerkers willen AI gebruiken voor hun werk, zoals mails schrijven en klantvragen beantwoorden. Wat besluit je?",
		"o": [
			"Iedereen mag de gratis AI-tool gebruiken die hij wil, en er alles in zetten wat hij nodig heeft. Dat scheelt veel tijd en kost niks.",
			"Ze mogen gratis AI-tools gebruiken, maar ik vraag of ze geen wachtwoorden of klantgegevens erin zetten. Dat is snel gezegd.",
			"We kiezen samen een paar AI-tools die mogen, en ik schrijf op wat er wel en niet in mag. Dat kost een middagje werk.",
			"We betalen voor een zakelijke AI-versie waarbij onze gegevens niet worden gebruikt om de AI te trainen. Ook zetten we AI in om aanvallen op te sporen, en een mens controleert altijd wat de AI doet. Dat kost een abonnement per persoon.",
		],
	},
	{
		"ch": "Het telefoontje",
		"q": "Welke regel stel je in voor betalingen door de financiële afdeling?",
		"o": [
			"Als ik bel of mail, maken ze het meteen over. Dat werkt snel en we missen geen deals.",
			"Bij grote bedragen laten ze me het via de mail nog even bevestigen.",
			"Bij grote bedragen bellen ze me altijd terug op mijn bekende nummer.",
			"Ze bellen me altijd terug op mijn bekende nummer, en een tweede collega moet de betaling goedkeuren. Dat maakt betalen wel langzamer.",
		],
	},
	{
		"ch": "200 medewerkers",
		"q": "Je bedrijf heeft nu 200 medewerkers. Laat je testen hoe veilig je bent (pentest)?",
		"o": [
			"Nee. Een pentest kost duizenden euro's, en we zijn nog nooit gehackt.",
			"Ik laat het doen als we een keer iets geks merken.",
			"Eén keer per jaar door een extern bedrijf. Dat is goed te betalen.",
			"Continu, en de belangrijkste systemen het vaakst. Dat is het duurst.",
		],
	},
	{
		"ch": "De hacker",
		"q": "Je ICT-afdeling ontdekt dat er al een tijdje een hacker op het netwerk zit. Wat doe je?",
		"o": [
			"Eerst zelf rustig kijken of het echt zo erg is. Een extern bureau inhuren kost meteen veel geld.",
			"Meteen alle systemen uitzetten. Hoe sneller hij eruit ligt, hoe beter.",
			"Alle verbindingen afsluiten en daarna een expert bellen.",
			"Het incidentplan volgen: eerst stil uitzoeken hoe ver de hacker is, dan pas afsluiten, en experts inschakelen. De hacker zit dan wel nog even op het netwerk.",
		],
	},
	{
		"ch": "Het datalek",
		"q": "Uit onderzoek blijkt dat de hacker klantgegevens heeft gestolen. Wat doe je?",
		"o": [
			"Ik meld het niet. Slecht nieuws kost klanten, en het lek is toch al gedicht.",
			"Ik wacht af of klanten er last van krijgen en meld het dan pas. Dan maak je niemand voor niks ongerust.",
			"Ik zoek eerst alles uit en meld het daarna binnen een paar weken, met het complete verhaal.",
			"Ik meld het binnen 72 uur bij de Autoriteit Persoonsgegevens (dat moet volgens de AVG) en ik licht de klanten in, ook al kost dat misschien klanten.",
		],
	},
]

# min = minimale score voor dit niveau
const LEVELS := [
	{"min": 0, "pill": "Open deur", "title": "[naam] stond wagenwijd open", "text": "Je hebt overal tijd en geld bespaard, maar hackers konden zo naar binnen lopen."},
	{"min": 12, "pill": "Kwetsbaar", "title": "[naam] was kwetsbaar", "text": "Je hebt een paar dingen geregeld, maar er zaten nog grote gaten in. Kleine bedrijven denken vaak dat het hen niet overkomt, terwijl hackers ze juist als oefening gebruiken."},
	{"min": 24, "pill": "Redelijk", "title": "[naam] was redelijk beveiligd, maar niet goed genoeg", "text": "Hier zitten de meeste bedrijven. Ze geven zichzelf gemiddeld een 7,1, maar dat is niet genoeg in een wereld waar iedereen met een AI-abonnement een aanval kan doen."},
	{"min": 36, "pill": "Goed beveiligd", "title": "[naam] was goed beveiligd", "text": "Je had de basis op orde en dacht aan de mensen, niet alleen aan de techniek."},
]
