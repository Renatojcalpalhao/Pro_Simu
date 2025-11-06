model dummy_model

// ---------------------------------------------------------------------
// PLACEHOLDERS (para o editor reconhecer as variáveis e espécies globais)
// ---------------------------------------------------------------------
species humanos {
    bool infectado;
    bool recuperado;
    float tempo_infeccao;
}

global {
    float prob_transmissao_mos_hum <- 0.3;
    float prob_transmissao_hum_mos <- 0.25;
    float base_taxa_reproducao_mosquito <- 0.2;
    int tempo_incubacao_mosquito <- 7;
    int vida_media_mosquito <- 25;
    int mosquitos_infectivos <- 0;
    int mosquitos_incubando <- 0;
}

// ---------------------------------------------------------------------
// ESPÉCIE: MOSQUITOS
// ---------------------------------------------------------------------
species mosquitos parent: agent skills: [moving] { 

    bool infectivo <- false;
    bool incubando <- false;
    int dias_vida <- 0;
    int dias_infeccao <- 0;
    point criadouro <- location;

    // ------------------------------------------------------------
    // REFLEXO 1: Atualiza estado biológico
    // ------------------------------------------------------------
    reflex atualizar_estado {
        dias_vida <- dias_vida + 1;

        // Morte natural (~25 dias)
        if (dias_vida > vida_media_mosquito) { 
            do die;
        }

        // Incubação viral
        if (incubando) {
            dias_infeccao <- dias_infeccao + 1;
            if (dias_infeccao >= tempo_incubacao_mosquito) { 
                infectivo <- true;
                incubando <- false;
                mosquitos_infectivos <- mosquitos_infectivos + 1;
            }
        }
    }

    // ------------------------------------------------------------
    // REFLEXO 2: Picada e transmissão
    // ------------------------------------------------------------
    reflex picar {
        humanos alvo <- one_of (humanos at_distance 10.0); 

        if (alvo != nil) {
            // Mosquito infecta humano
            if (infectivo and not alvo.infectado and not alvo.recuperado) {
                if (flip(prob_transmissao_mos_hum)) { 
                    alvo.infectado <- true;
                    alvo.tempo_infeccao <- 0.0;
                }
            }

            // Humano infecta mosquito
            if (alvo.infectado and not infectivo and not incubando) {
                if (flip(prob_transmissao_hum_mos)) { 
                    incubando <- true;
                    dias_infeccao <- 0;
                    mosquitos_incubando <- mosquitos_incubando + 1;
                }
            }
        }
    }

    // ------------------------------------------------------------
    // REFLEXO 3: Reprodução
    // ------------------------------------------------------------
    reflex reproducao {
        if (flip(base_taxa_reproducao_mosquito)) { 
            create mosquitos number: rnd(1, 3) {
                location <- myself.location + {rnd(-10, 10), rnd(-10, 10)};
                criadouro <- myself.criadouro;
            }
        }
    }

    // ------------------------------------------------------------
    // REFLEXO 4: Movimento aleatório
    // ------------------------------------------------------------
    reflex mover {
        point destino <- location + {rnd(-5, 5), rnd(-5, 5)};
        if (world.shape overlaps destino) {
            location <- destino;
        }
    }

    // ------------------------------------------------------------
    // ASPECTO VISUAL
    // ------------------------------------------------------------
    aspect base {
        if (infectivo) {
            draw circle(0.8) color: rgb(255,0,0);      // vermelho = infectivo
        } else if (incubando) {
            draw circle(0.8) color: rgb(255,165,0);    // laranja = incubando
        } else {
            draw circle(0.8) color: rgb(128,128,128);  // cinza = normal
        }
    }
}
