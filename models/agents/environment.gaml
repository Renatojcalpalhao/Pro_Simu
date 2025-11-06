model environment_module

// ------------------------------------------------------------------
// PLACEHOLDER PARA EVITAR ERROS NO EDITOR
// (Será substituído pela espécie real no Pro_Simu.gaml)
// ------------------------------------------------------------------
species humanos {
    bool infectado;
    bool recuperado;
}

global {
    float temperatura_externa <- 28.0;
    float umidade <- 75.0;
    float precipitacao <- 4.0;
    int total_infectados <- 0;
    int total_recuperados <- 0;
    int total_casos_reportados <- 0;
}

// ============================================================
// ESPÉCIE: ENVIRONMENT
// ============================================================
species environment parent: agent {

    float temperatura_local  <- 28.0;
    float umidade_local      <- 75.0;
    float precipitacao_local <- 4.0;

    reflex atualizar_ambiente {

        // Atualiza clima local
        temperatura_local  <- temperatura_local  + rnd(-0.3, 0.3);
        umidade_local      <- umidade_local      + rnd(-1.0, 1.0);
        precipitacao_local <- max(0.0, precipitacao_local + rnd(-0.4, 0.4));

        // Atualiza globais (locais de validação)
        temperatura_externa <- temperatura_local;
        umidade             <- umidade_local;
        precipitacao        <- precipitacao_local;

        // Atualiza métricas epidemiológicas
        total_infectados       <- count(humanos where each.infectado);
        total_recuperados      <- count(humanos where each.recuperado);
        total_casos_reportados <- total_infectados + total_recuperados;

        // Log visual no console
        write "🌡️ Atualização ambiental: Temp=" + string(temperatura_externa)
              + "°C | Umid=" + string(umidade)
              + "% | Chuva=" + string(precipitacao) + " mm";
    }

    aspect base {
        draw circle(4) color: rgb(211,211,211) border: rgb(0,0,0);
        draw "Ambiente" size: 12 color: rgb(0,0,0);
    }
}
