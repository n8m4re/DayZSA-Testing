private ["_agent","_v"];

_agent = _this;

_arrPrimWep = [
["AK101","Att_Suppressor_AK","Att_Optic_PSO1","Att_Optic_Kashtan","Att_Handguard_AK_Rail_Black","Att_Bipod_Atlas","Att_Buttstock_AK_Plastic","M_ak101_30Rnd","M_ak101_30Rnd","M_ak101_30Rnd","Ammo_556","Ammo_556","Ammo_556","Ammo_556"],
["AK74","Att_Suppressor_AK","Att_Optic_PSO1","Att_Optic_Kashtan","Att_Handguard_AK_Rail_Black","Att_Bipod_Atlas","Att_Buttstock_AK74","M_ak74_30Rnd","M_ak74_30Rnd","M_ak74_30Rnd","Ammo_545","Ammo_545","Ammo_545","Ammo_545"],
["AKM","Att_Suppressor_AK","Att_Optic_PSO1","Att_Optic_Kashtan","Att_Handguard_AK_Rail_Black","Att_Bipod_Atlas","Att_Buttstock_AK_Wood","M_akm_drum","M_akm_drum","Ammo_762x39","Ammo_762x39","Ammo_762x39","Ammo_762x39"],
["AugSteyr","Att_Suppressor_M4","M_STANAG_30Rnd_Coupled","M_STANAG_30Rnd_Coupled","M_STANAG_30Rnd_Coupled","Ammo_556","Ammo_556","Ammo_556","Ammo_556"],
["M4A1","Att_Suppressor_M4","Att_Handguard_M4RIS","Att_Buttstock_M4MP","Att_Bipod_Atlas","Att_Optic_ACOG","Att_Optic_M4T3NRDS","M_STANAG_30Rnd_Coupled","M_STANAG_30Rnd_Coupled","M_STANAG_30Rnd_Coupled","Ammo_556","Ammo_556","Ammo_556","Ammo_556"],
["Mosin9130","Att_Compensator_Mosin","Att_Optic_PUScope","CLIP_762_5Rnd","CLIP_762_5Rnd","CLIP_762_5Rnd","Ammo_762","Ammo_762","Ammo_762","Ammo_762"],
["SVD","Att_Optic_PSO1","M_svd_10Rnd","M_svd_10Rnd","M_svd_10Rnd","M_svd_10Rnd","Ammo_762","Ammo_762","Ammo_762","Ammo_762"],
["SKS","Att_Compensator_Mosin","Att_Optic_PUScope","Clip_762x39_10Rnd","Clip_762x39_10Rnd","Clip_762x39_10Rnd","Ammo_762x39","Ammo_762x39","Ammo_762x39","Ammo_762x39"],
["VSS","Att_Optic_PSO11","M_Vss_10Rnd","M_Vss_10Rnd","M_Vss_10Rnd","M_Vss_10Rnd","Ammo_9x39","Ammo_9x39","Ammo_9x39","Ammo_9x39"],
["Winchester70","Att_Optic_Hunting","CLIP_308Win_Snaploader","CLIP_308Win_Snaploader","CLIP_308Win_Snaploader","Ammo_308Win","Ammo_308Win","Ammo_308Win","Ammo_308Win"]
];

_arrSecWep = [
["MP5K","M_MP5_30Rnd","M_MP5_30Rnd","M_MP5_15Rnd","M_MP5_15Rnd"],
["UMP45","M_UMP_25Rnd","M_UMP_25Rnd","M_UMP_25Rnd"],
["DE_Gold","M_DE_9rnd","M_DE_9rnd","M_DE_9rnd"]
];

_arrayCloth = [
["M65_Jacket_Black","CargoPants_Black","Bagdrybag_Black","WorkingGloves_Black","GorkaHelmet_complete_Black","JoeyXSunGlasses","BalaclavaMask_Blackskull","MilitaryBoots_Black","HighCapacityVest_Black"],
["Gorka_up_summer","Gorka_pants_summer","BagTortilla","WorkingGloves_Brown","GorkaHelmet_complete_Green","JoeyXSunGlasses","BalaclavaMask_Green","MilitaryBoots_Black","PlateCarrierComplete"],
["Gorka_up_flat","Gorka_pants_flat","BagTortilla","WorkingGloves_Brown","GorkaHelmet_complete_Green","JoeyXSunGlasses","BalaclavaMask_Green","MilitaryBoots_Black","PlateCarrierComplete"],
["TTsKO_Jacket_Camo","ttsko_pants_Beige","BagHunting","WorkingGloves_Brown","GorkaHelmet_complete_Green","JoeyXSunGlasses","BandanaMask_camopattern","MilitaryBoots_Black","PlateCarrierComplete"],
["M65_Jacket_Khaki","CargoPants_Green","BagHunting","WorkingGloves_Yellow","GorkaHelmet_complete_Green","JoeyXSunGlasses","BandanaMask_greenpattern","MilitaryBoots_Redpunk","HighCapacityVest_Olive"]
];


{_v = _agent createInInventory _x} forEach (_arrayCloth select floor(random(count _arrayCloth)));
{_v = _agent createInInventory _x} forEach (_arrPrimWep select floor(random(count _arrPrimWep)));
{_v = _agent createInInventory _x} forEach (_arrSecWep select floor(random(count _arrSecWep)));

_v = _agent createInInventory "FirefighterAxe";
_v = _agent createInInventory "CombatKnife";

