class ChernarusPlusSpawner {
	class AISpawnerParams {
		territoriesFiles[] = {"test\domestic_animals_territories.xml", "test\red_deer_territories.xml", "test\roe_deer_territories.xml", "test\wild_boar_territories.xml", "test\pig_territories.xml", "test\hen_territories.xml", "test\wolf_territories.xml", "test\hare_territories.xml", "test\zombie_territories.xml"};
		
		class HerdDeer {
			usableTerritories[] = {"red_deer_territories"};
			groupBehaviourTemplateName = "DZDeerGroupBeh";
			herdsCount = 5;
			
			class AgentTypeMale {
				agentConfigName[] = {"Animal_CervusElaphus"};
				countMin = 1;
				countMax = 1;
			};
			
			class AgentTypeFemale {
				agentConfigName[] = {"Animal_CervusElaphusF"};
				countMin = 3;
				countMax = 5;
			};
		};
		
		class HerdCow {
			usableTerritories[] = {"domestic_animals_territories"};
			groupBehaviourTemplateName = "DZdomesticGroupBeh";
			herdsCount = 5;
			
			class AgentTypeMale {
				agentConfigName[] = {"Animal_BosTaurus_Brown", "Animal_BosTaurus_Spotted", "Animal_BosTaurus_White"};
				countMin = 1;
				countMax = 2;
			};
			
			class AgentTypeFemale {
				agentConfigName[] = {"Animal_BosTaurusF_Brown", "Animal_BosTaurusF_Spotted", "Animal_BosTaurusF_White"};
				countMin = 3;
				countMax = 5;
			};
		};
		
		class HerdRoeDeer {
			usableTerritories[] = {"roe_deer_territories"};
			groupBehaviourTemplateName = "DZDeerGroupBeh";
			herdsCount = 5;
			
			class AgentTypeMale {
				agentConfigName[] = {"Animal_CapreolusCapreolus"};
				countMin = 1;
				countMax = 1;
			};
			
			class AgentTypeFemale {
				agentConfigName[] = {"Animal_CapreolusCapreolusF"};
				countMin = 4;
				countMax = 4;
			};
		};
		
		class HerdWolf {
			usableTerritories[] = {"wolf_territories"};
			groupBehaviourTemplateName = "DZWolfGroupBeh";
			herdsCount = 3;
			
			class AgentTypeMale {
				agentConfigName[] = {"Animal_CanisLupus_White"};
				countMin = 1;
				countMax = 1;
			};
			
			class AgentTypeFemale {
				agentConfigName[] = {"Animal_CanisLupus_Grey"};
				countMin = 3;
				countMax = 5;
			};
		};
		
		class AmbientHen {
			usableTerritories[] = {"hen_territories"};
			groupBehaviourTemplateName = "DZAmbientLifeGroupBeh";
			globalCountMax = 50;
			zoneCountMin = 1;
			zoneCountMax = 1;
			playerSpawnRadiusNear = 25;
			playerSpawnRadiusFar = 75;
			
			class AgentTypeMale {
				agentConfigName[] = {"Animal_GallusGallusDomesticus"};
				agentSpawnChance[] = {"1"};
			};
			
			class AgentTypeFemale {
				agentConfigName[] = {"Animal_GallusGallusDomesticusF_Brown", "Animal_GallusGallusDomesticusF_Spotted", "Animal_GallusGallusDomesticusF_White"};
				agentSpawnChance[] = {"1", "10", "20"};
			};
			agentTypeSpawnChance[] = {"1", "3"};
		};
		
		class AmbientHare {
			usableTerritories[] = {"hare_territories"};
			groupBehaviourTemplateName = "DZAmbientLifeGroupBeh";
			globalCountMax = 0;
			zoneCountMin = 3;
			zoneCountMax = 5;
			playerSpawnRadiusNear = 15;
			playerSpawnRadiusFar = 200;
			
			class AgentTypeMale {
				agentConfigName[] = {"Animal_LepusEuropaeus"};
				agentSpawnChance[] = {"1"};
			};
			
			class AgentTypeFemale {
				agentConfigName[] = {"Animal_LepusEuropaeus"};
				agentSpawnChance[] = {"1"};
			};
			agentTypeSpawnChance[] = {"1", "3"};
		};
		
		class HerdZombieTest {
			usableTerritories[] = {"zombie_territories"};
			groupBehaviourTemplateName = "DZdomesticGroupBeh";
			herdsCount = 0;
			
			class AgentTypeMale {
				agentConfigName[] = {"ZombieMale3_NewAI"};
				countMin = 0;
				countMax = 0;
			};
			
			class AgentTypeFemale {
				agentConfigName[] = {"ZombieFemale3_NewAI"};
				countMin = 0;
				countMax = 0;
			};
		};
	};
};
