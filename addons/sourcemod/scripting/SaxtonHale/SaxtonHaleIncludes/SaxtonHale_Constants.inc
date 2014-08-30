#define ME 2048

#define EF_BONEMERGE            (1 << 0)
#define EF_BONEMERGE_FASTCULL   (1 << 7)

#define PLUGIN_VERSION "1.50"

#define HALEHHH_TELEPORTCHARGETIME 2
#define HALE_JUMPCHARGETIME 1

#define HALEHHH_TELEPORTCHARGE (25 * HALEHHH_TELEPORTCHARGETIME)
#define HALE_JUMPCHARGE (25 * HALE_JUMPCHARGETIME)

#define CBS_MAX_ARROWS 9

#define EASTER_BUNNY_ON
#define BunnyModel "models/player/saxton_hale/easter_demo.mdl"
#define BunnyModelPrefix "models/player/saxton_hale/easter_demo"
#define EggModel "models/player/saxton_hale/w_easteregg.mdl"
#define EggModelPrefix "models/player/saxton_hale/w_easteregg"
#define ReloadEggModel "models/player/saxton_hale/c_easter_cannonball.mdl"
#define ReloadEggModelPrefix "models/player/saxton_hale/c_easter_cannonball"

stock const String:BunnyWin[][] = {
	"vo/demoman_gibberish01.wav",
	"vo/demoman_gibberish12.wav",
	"vo/demoman_cheers02.wav",
	"vo/demoman_cheers03.wav",
	"vo/demoman_cheers06.wav",
	"vo/demoman_cheers07.wav",
	"vo/demoman_cheers08.wav",
	"vo/taunts/demoman_taunts12.wav"
};
stock const String:BunnyJump[][] = {
	"vo/demoman_gibberish07.wav",
	"vo/demoman_gibberish08.wav",
	"vo/demoman_laughshort01.wav",
	"vo/demoman_positivevocalization04.wav"
};
stock const String:BunnyRage[][] = {
	"vo/demoman_positivevocalization03.wav",
	"vo/demoman_dominationscout05.wav",
	"vo/demoman_cheers02.wav"
};
stock const String:BunnyFail[][] = {
	"vo/demoman_gibberish04.wav",
	"vo/demoman_gibberish10.wav",
	"vo/demoman_jeers03.wav",
	"vo/demoman_jeers06.wav",
	"vo/demoman_jeers07.wav",
	"vo/demoman_jeers08.wav"
};
stock const String:BunnyKill[][] = {
	"vo/demoman_gibberish09.wav",
	"vo/demoman_cheers02.wav",
	"vo/demoman_cheers07.wav",
	"vo/demoman_positivevocalization03.wav"
};
stock const String:BunnySpree[][] = {
	"vo/demoman_gibberish05.wav",
	"vo/demoman_gibberish06.wav",
	"vo/demoman_gibberish09.wav",
	"vo/demoman_gibberish11.wav",
	"vo/demoman_gibberish13.wav",
	"vo/demoman_autodejectedtie01.wav"
};
stock const String:BunnyLast[][] = {
	"vo/taunts/demoman_taunts05.wav",
	"vo/taunts/demoman_taunts04.wav",
	"vo/demoman_specialcompleted07.wav"
};
stock const String:BunnyPain[][] = {
	"vo/demoman_sf12_badmagic01.wav",
	"vo/demoman_sf12_badmagic07.wav",
	"vo/demoman_sf12_badmagic10.wav"
};
stock const String:BunnyStart[][] = {
	"vo/demoman_gibberish03.wav",
	"vo/demoman_gibberish11.wav"
};
stock const String:BunnyRandomVoice[][] = {
	"vo/demoman_positivevocalization03.wav",
	"vo/demoman_jeers08.wav",
	"vo/demoman_gibberish03.wav",
	"vo/demoman_cheers07.wav",
	"vo/demoman_sf12_badmagic01.wav",
	"vo/burp02.wav",
	"vo/burp03.wav",
	"vo/burp04.wav",
	"vo/burp05.wav",
	"vo/burp06.wav",
	"vo/burp07.wav"
};

#define HaleModel "models/player/saxton_hale/saxton_hale.mdl"
#define HaleModelPrefix "models/player/saxton_hale/saxton_hale"
#define CBSModel "models/player/saxton_hale/cbs_v4.mdl"
#define CBSModelPrefix "models/player/saxton_hale/cbs_v4"
#define HaleYellName "saxton_hale/saxton_hale_responce_1a.wav"
#define HaleRageSoundB "saxton_hale/saxton_hale_responce_1b.wav"
#define HaleComicArmsFallSound "saxton_hale/saxton_hale_responce_2.wav"
#define HaleLastB "vo/announcer_am_lastmanalive"
#define HaleEnabled QueuePanelH(Handle:0, MenuAction:0, 9001, 0)
#define HaleKSpree "saxton_hale/saxton_hale_responce_3.wav"
#define HaleKSpree2 "saxton_hale/saxton_hale_responce_4.wav"    //this line is broken and unused
#define VagineerModel "models/player/saxton_hale/vagineer_v134.mdl"
#define VagineerModelPrefix "models/player/saxton_hale/vagineer_v134"
#define VagineerLastA "saxton_hale/lolwut_0.wav"
#define VagineerRageSound "saxton_hale/lolwut_2.wav"
#define VagineerStart "saxton_hale/lolwut_1.wav"
#define VagineerKSpree "saxton_hale/lolwut_3.wav"
#define VagineerKSpree2 "saxton_hale/lolwut_4.wav"
#define VagineerHit "saxton_hale/lolwut_5.wav"
#define WrenchModel "models/weapons/w_models/w_wrench.mdl"
#define ShivModel "models/weapons/c_models/c_wood_machete/c_wood_machete.mdl"
#define HHHModel "models/player/saxton_hale/hhh_jr_mk3.mdl"
#define HHHModelPrefix "models/player/saxton_hale/hhh_jr_mk3"
#define AxeModel "models/weapons/c_models/c_headtaker/c_headtaker.mdl"
#define HHHLaught "vo/halloween_boss/knight_laugh"
#define HHHRage "vo/halloween_boss/knight_attack01.wav"
#define HHHRage2 "vo/halloween_boss/knight_alert.wav"
#define HHHAttack "vo/halloween_boss/knight_attack"
#define CBS0 "vo/sniper_specialweapon08.wav"
#define CBS1 "vo/taunts/sniper_taunts02.wav"
#define CBS2 "vo/sniper_award"
#define CBS3 "vo/sniper_battlecry03.wav"
#define CBS4 "vo/sniper_domination"
#define HHHTheme "ui/holiday/gamestartup_halloween.mp3"
#define CBSTheme "saxton_hale/the_millionaires_holiday.mp3"
#define CBSJump1 "vo/sniper_specialcompleted02.wav"
//===New responces===
#define HaleRoundStart "saxton_hale/saxton_hale_responce_start" //1-5
#define HaleJump "saxton_hale/saxton_hale_responce_jump"            //1-2
#define HaleRageSound "saxton_hale/saxton_hale_responce_rage"           //1-4
#define HaleKillMedic "saxton_hale/saxton_hale_responce_kill_medic.wav"
#define HaleKillSniper1 "saxton_hale/saxton_hale_responce_kill_sniper1.wav"
#define HaleKillSniper2 "saxton_hale/saxton_hale_responce_kill_sniper2.wav"
#define HaleKillSpy1 "saxton_hale/saxton_hale_responce_kill_spy1.wav"
#define HaleKillSpy2 "saxton_hale/saxton_hale_responce_kill_spy2.wav"
#define HaleKillEngie1 "saxton_hale/saxton_hale_responce_kill_eggineer1.wav"
#define HaleKillEngie2 "saxton_hale/saxton_hale_responce_kill_eggineer2.wav"
#define HaleKSpreeNew "saxton_hale/saxton_hale_responce_spree"  //1-5
#define HaleWin "saxton_hale/saxton_hale_responce_win"          //1-2
#define HaleLastMan "saxton_hale/saxton_hale_responce_lastman"  //1-5
//#define HaleLastMan2Fixed "saxton_hale/saxton_hale_responce_lastman2.wav"
#define HaleFail "saxton_hale/saxton_hale_responce_fail"            //1-3
//===1.32 responces===
#define HaleJump132 "saxton_hale/saxton_hale_132_jump_" //1-2
#define HaleStart132 "saxton_hale/saxton_hale_132_start_"   //1-5
#define HaleKillDemo132  "saxton_hale/saxton_hale_132_kill_demo.wav"
#define HaleKillEngie132  "saxton_hale/saxton_hale_132_kill_engie_" //1-2
#define HaleKillHeavy132  "saxton_hale/saxton_hale_132_kill_heavy.wav"
#define HaleKillScout132  "saxton_hale/saxton_hale_132_kill_scout.wav"
#define HaleKillSpy132  "saxton_hale/saxton_hale_132_kill_spie.wav"
#define HaleKillPyro132  "saxton_hale/saxton_hale_132_kill_w_and_m1.wav"
#define HaleSappinMahSentry132  "saxton_hale/saxton_hale_132_kill_toy.wav"
#define HaleKillKSpree132  "saxton_hale/saxton_hale_132_kspree_"    //1-2
#define HaleKillLast132  "saxton_hale/saxton_hale_132_last.wav"
#define HaleStubbed132 "saxton_hale/saxton_hale_132_stub_"  //1-4
//===New Vagineer's responces===
#define VagineerRoundStart "saxton_hale/vagineer_responce_intro.wav"
#define VagineerJump "saxton_hale/vagineer_responce_jump_"          //1-2
#define VagineerRageSound2 "saxton_hale/vagineer_responce_rage_"            //1-4
#define VagineerKSpreeNew "saxton_hale/vagineer_responce_taunt_"        //1-5
#define VagineerFail "saxton_hale/vagineer_responce_fail_"          //1-2
#define SOUNDEXCEPT_MUSIC 0
#define SOUNDEXCEPT_VOICE 1

#define VSHFLAG_HELPED          (1 << 0)
#define VSHFLAG_UBERREADY       (1 << 1)
#define VSHFLAG_NEEDSTODUCK (1 << 2)
#define VSHFLAG_BOTRAGE     (1 << 3)
#define VSHFLAG_CLASSHELPED (1 << 4)
#define VSHFLAG_HASONGIVED  (1 << 5)

stock const String:haleversiontitles[][] =     //the last line of this is what determines the displayed plugin version
{
	"1.0",
	"1.1",
	"1.11",
	"1.12",
	"1.2",
	"1.22",
	"1.23",
	"1.24",
	"1.25",
	"1.26",
	"Christian Brutal Sniper",
	"1.28",
	"1.29",
	"1.30",
	"1.31",
	"1.32",
	"1.33",
	"1.34",
	"1.35",
	"1.35_3",
	"1.36",
	"1.36",
	"1.36",
	"1.36",
	"1.36",
	"1.36",
	"1.362",
	"1.363",
	"1.364",
	"1.365",
	"1.366",
	"1.367",
	"1.368",
	"1.369",
	"1.369",
	"1.369",
	"1.37",
	"1.37b",    //15 Nov 2011
	"1.38",
	"1.38",
	"1.39beta",
	"1.39beta",
	"1.39beta",
	"1.39c",
	"1.39c",
	"1.39c",
	"1.40",
	"1.41",
	"1.42",
	"1.43",
	"1.43",
	"1.43",
	"1.44",
	"1.44",
	"1.45",
	"1.45",
	"1.45",
	"1.45",
	"1.45",
	"1.46",
	"1.46",
	"1.46",
	"1.47",
	"1.47",
	"1.48",
	"1.48",
	"1.49",
	"1.50"
};
stock const String:haleversiondates[][] =
{
	"--",
	"--",
	"--",
	"--",
	"--",
	"--",
	"--",
	"--",
	"--",
	"--",
	"--",
	"--",
	"--",
	"--",
	"--",
	"--",
	"--",
	"--",
	"--",
	"--",
	"--",
	"--",
	"--",
	"--",
	"--",
	"--",
	"--",
	"--",
	"--",
	"--",
	"--",
	"25 Aug 2011",
	"26 Aug 2011",
	"09 Oct 2011",
	"09 Oct 2011",
	"09 Oct 2011",
	"15 Nov 2011",
	"15 Nov 2011",
	"17 Dec 2011",
	"17 Dec 2011",
	"05 Mar 2012",
	"05 Mar 2012",
	"05 Mar 2012",
	"16 Jul 2012",
	"16 Jul 2012",
	"16 Jul 2012",
	"10 Oct 2012",
	"25 Feb 2013",
	"30 Mar 2013",
	"14 Jul 2014",
	"15 Jul 2014",
	"15 Jul 2014",
	"15 Jul 2014",
	"15 Jul 2014",
	"18 Jul 2014",
	"17 Jul 2014",
	"17 Jul 2014",
	"17 Jul 2014",
	"17 Jul 2014",
	"27 Jul 2014",
	"19 Jul 2014",
	"19 Jul 2014",
	"04 Aug 2014",
	"04 Aug 2014",
	"14 Aug 2014",
	"14 Aug 2014",
	"18 Aug 2014",
	"29 Aug 2014"
};
stock const maxversion = (sizeof(haleversiontitles) - 1);

