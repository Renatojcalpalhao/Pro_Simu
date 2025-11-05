model dados_inc

global {

    // =============================================================
    // 🌦️ VARIÁVEIS CLIMÁTICAS E AMBIENTAIS
    // =============================================================
    float temperatura_externa <- 28.0;
    float umidade <- 75.0;
    float precipitacao <- 4.0;

    // =============================================================
    // 🦟 PARÂMETROS BIOLÓGICOS DOS MOSQUITOS
    // =============================================================
    float base_taxa_reproducao_mosquito <- 0.25;   // probabilidade diária de reprodução
    float prob_transmissao_mos_hum <- 0.3;         // mosquito → humano
    float prob_transmissao_hum_mos <- 0.25;        // humano → mosquito
    int tempo_incubacao_mosquito <- 7;             // dias até o mosquito ficar infectivo

    // =============================================================
    // 🧍‍♂️ PARÂMETROS DOS HUMANOS
    // =============================================================
    float taxa_recuperacao <- 0.15;
    float taxa_imunidade <- 0.8;
    float mobilidade_media <- 100.0;

    // =============================================================
    // 📈 VARIÁVEIS DE MÉTRICAS (ATUALIZADAS PELO MODELO PRINCIPAL)
    // =============================================================
    int total_casos_reportados <- 0;
    int total_infectados <- 0;
    int total_recuperados <- 0;

    // =============================================================
    // ⚙️ AÇÕES GLOBAIS — CHAMADAS PELO MODELO BASE
    // =============================================================

    // Atualiza condições ambientais
    action atualizar_dados_ambiente {
        temperatura_externa <- temperatura_externa + rnd(-1.0, 1.0);
        umidade <- umidade + rnd(-3.0, 3.0);
        precipitacao <- max(0.0, precipitacao + rnd(-1.0, 1.5));

        temperatura_externa <- min(35.0, max(20.0, temperatura_externa));
        umidade <- min(95.0, max(40.0, umidade));
        precipitacao <- min(15.0, max(0.0, precipitacao));
    }

    // Apenas imprime métricas — o cálculo será feito no modelo principal
    action exibir_metricas {
        write "📊 Dia " + cycle
            + " | Infectados: " + total_infectados
            + " | Recuperados: " + total_recuperados
            + " | Casos Totais: " + total_casos_reportados;
    }
}
