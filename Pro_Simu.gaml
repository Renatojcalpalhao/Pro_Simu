model Pro_Simu

// =============================================================
// IMPORTS
// =============================================================
import "models/agents/environment.gaml"
import "models/agents/area_risco.gaml"
import "models/agents/human.gaml"
import "models/agents/mosquito.gaml"
import "includes/dados.gaml"

// =============================================================
// MODELO GLOBAL — SIMULAÇÃO DA DENGUE
// =============================================================
global {

    // ------------------------------------------
    // VARIÁVEIS CLIMÁTICAS E AMBIENTAIS
    // ------------------------------------------
    float temperatura_externa <- 28.0;
    float umidade <- 75.0;
    float precipitacao <- 4.0;

    // ------------------------------------------
    // PARÂMETROS GERAIS DA SIMULAÇÃO
    // ------------------------------------------
    int nb_humanos <- 100;
    int nb_mosquitos <- 150;
    int duracao_simulacao <- 20; 
    list<point> criadouros_potenciais <- [];

    // ------------------------------------------
    // PARÂMETROS EPIDEMIOLÓGICOS
    // ------------------------------------------
    float prob_contagio <- 0.3;
    float tempo_medio_recuperacao <- 10.0;
    float prob_transmissao_mos_hum <- 0.3;
    float prob_transmissao_hum_mos <- 0.25;
    float base_taxa_reproducao_mosquito <- 0.20;
    int tempo_incubacao_mosquito <- 7;
    int vida_media_mosquito <- 25;

    // ------------------------------------------
    // LOCALIZAÇÕES
    // ------------------------------------------
    point localizacao_casa <- point(0, 0);
    point localizacao_trabalho <- point(50, 50);
    point area_criadouro <- point(0, 0);

    // ------------------------------------------
    // MÉTRICAS
    // ------------------------------------------
    int total_infectados <- 0;
    int total_recuperados <- 0;
    int total_casos_reportados <- 0;
    int mosquitos_infectivos <- 0;
    int mosquitos_incubando <- 0;

    // ------------------------------------------
    // INICIALIZAÇÃO DO MODELO
    // ------------------------------------------
    init {
        write "🦟 Iniciando simulação da dengue...";
        write "👥 Humanos: " + nb_humanos + " | 🪰 Mosquitos: " + nb_mosquitos;

        // Criação das espécies principais
        create humanos number: nb_humanos;
        create mosquitos number: nb_mosquitos;
        create area_risco number: 5;
        create environment number: 1; 

        // Posicionamento inicial
        ask humanos { location <- any_location_in(world.shape); }
        ask mosquitos { location <- any_location_in(world.shape); }

        // ----------------------------------------------------------
        // INJEÇÃO DOS PARÂMETROS GLOBAIS NOS HUMANOS
        // (necessário porque human.gaml é autocontido)
        // ----------------------------------------------------------
        ask humanos {
            casa                  <- localizacao_casa;
            trabalho              <- localizacao_trabalho;
            prob_contagio_local   <- prob_contagio;
            tempo_medio_rec_local <- tempo_medio_recuperacao;
        }

        // Infectar alguns humanos no início
        ask humanos among: 10 { infectado <- true; }

        // Inicializa variáveis ambientais
        do atualizar_dados_ambiente;
        write "✅ Modelo carregado com sucesso.";
    }

    // ------------------------------------------
    // AÇÃO: Atualiza variáveis ambientais
    // ------------------------------------------
    action atualizar_dados_ambiente {
        temperatura_externa <- temperatura_externa + rnd(-0.3, 0.3);
        umidade <- umidade + rnd(-1.0, 1.0);
        precipitacao <- max(0.0, precipitacao + rnd(-0.4, 0.4));
    }
}

// =============================================================
// EXPERIMENTO PRINCIPAL — SIMULAÇÃO GUIADA
// =============================================================
experiment santo_amaro_20d type: gui {

    // ------------------------------------------
    // PARÂMETROS DO EXPERIMENTO
    // ------------------------------------------
    parameter "População de Humanos" var: nb_humanos;
    parameter "População de Mosquitos" var: nb_mosquitos;
    parameter "Duração da Simulação (dias)" var: duracao_simulacao min: 1 max: 365;
    parameter "Probabilidade de Contágio Humano" var: prob_contagio min: 0.0 max: 1.0 step: 0.05;
    parameter "Probabilidade Mosq -> Humano" var: prob_transmissao_mos_hum min: 0.0 max: 1.0 step: 0.05;

    // ------------------------------------------
    // SAÍDAS VISUAIS
    // ------------------------------------------
    output {

        // Mapa principal da simulação
        display "Mapa de Simulação" type: 2d {
            species humanos color: (
                infectado ? #red :
                (recuperado ? #green : #blue)
            );

            species mosquitos color: (
                infectivo ? #orange : #gray
            );

            species area_risco border: #black color: (
                (nivel_risco = 5) ? #red :
                ((nivel_risco = 4) ? #orange :
                ((nivel_risco = 3) ? #yellow : #green))
            );

            species environment color: #lightgray;
        }

        // Gráficos e monitores
        display "Gráficos de Métricas" type: 2d {

            chart "Casos de Dengue" type: series {
                data "Infectados" value: count(humanos where (infectado)) color: #red;
                data "Recuperados" value: count(humanos where (recuperado)) color: #green;
                data "Suscetíveis" value: count(humanos where (not infectado and not recuperado)) color: #blue;
            }

            chart "Clima" type: series {
                data "Temperatura (°C)" value: temperatura_externa color: #orange;
                data "Chuva (mm)" value: precipitacao color: #blue;
                data "Umidade (%)" value: umidade color: #aqua;
            }

            chart "Mosquitos" type: series {
                data "Infectivos" value: mosquitos_infectivos color: #purple; 
                data "Incubando" value: mosquitos_incubando color: #orange;
                data "Total" value: count(mosquitos) color: #gray;
            }

            monitor "Total Infectados" value: total_infectados;
            monitor "Total Recuperados" value: total_recuperados;
            monitor "Casos Reportados" value: total_casos_reportados;
            monitor "Mosquitos Infectivos" value: mosquitos_infectivos;
        }
    } 
}
