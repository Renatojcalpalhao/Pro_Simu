model dummy_model

// ============================================================
// ESPÉCIE: HUMANOS (autocontida, sem depender de `global.`)
// ============================================================
species humanos parent: agent skills: [moving] { 
    
    // ---- Parâmetros/atributos que ANTES vinham do `global` ----
    point casa      <- {0, 0};      // será preenchido pelo modelo principal
    point trabalho  <- {50, 50};    // será preenchido pelo modelo principal
    float prob_contagio_local        <- 0.3;  // idem
    float tempo_medio_rec_local      <- 10.0; // idem

    // ------------------------------------------
    // ATRIBUTOS DE SAÚDE
    // ------------------------------------------
    bool  infectado       <- false;
    bool  recuperado      <- false;
    float tempo_infeccao  <- 0.0;
    bool  em_casa         <- true; 

    // ------------------------------------------
    // REFLEXO: MOVIMENTO (agora sem `global.`)
    // ------------------------------------------
    reflex mover {
        int hora <- int(cycle mod 24);

        if (hora >= 7 and hora < 10) {
            em_casa <- false;
            do goto target: trabalho speed: 1.5;
        } else if (hora >= 17 and hora < 20) {
            em_casa <- true;
            do goto target: casa speed: 1.5;
        } else {
            do wander amplitude: 30.0;
        }
    }
    
    // ------------------------------------------
    // REFLEXO: ATUALIZAR SAÚDE (sem `global.`)
    // ------------------------------------------
    reflex atualizar_saude when: infectado {
        tempo_infeccao <- tempo_infeccao + 1;
        if (tempo_infeccao > tempo_medio_rec_local) {
            infectado <- false;
            recuperado <- true;
        }
    }
    
    // ------------------------------------------
    // REFLEXO: CONTAGIAR (sem `global.`)
    // ------------------------------------------
    reflex contagiar when: (not infectado and not recuperado) {
        list<humanos> vizinhos_infectados <- humanos at_distance 10.0 where each.infectado;
        if not empty(vizinhos_infectados) {
            if flip(prob_contagio_local) {
                infectado <- true;
                tempo_infeccao <- 0.0;
            }
        }
    }
    
    // ------------------------------------------
    // ASPECTO VISUAL
    // ------------------------------------------
    aspect base {
        if (infectado) {
            draw circle(2) color: #red;
        } else if (recuperado) {
            draw circle(2) color: #green;
        } else {
            draw circle(2) color: #blue;
        }
        if (em_casa) {
            draw square(3) color: #black depth: 0.0;
        }
    }
}
