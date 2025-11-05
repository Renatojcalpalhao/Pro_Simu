
species humanos parent: agent skills: [moving] { 
    
    // ------------------------------------------
    // ATRIBUTOS DE SAÚDE
    // ------------------------------------------
    bool infectado <- false;
    bool recuperado <- false;

    // Variáveis internas
    float tempo_infeccao <- 0.0;
    bool em_casa <- true; 

    // ------------------------------------------
    // REFLEXO: MOVIMENTO
    // ------------------------------------------
    reflex mover {
        int hora <- int(cycle mod 24);

        if (hora >= 7 and hora < 10) {
            em_casa <- false;
            do goto target: global.localizacao_trabalho speed: 1.5;
        } else if (hora >= 17 and hora < 20) {
            em_casa <- true;
            do goto target: global.localizacao_casa speed: 1.5;
        } else {
            do wander amplitude: 30.0;
        }
    }
    
    // ------------------------------------------
    // REFLEXO: ATUALIZAR SAÚDE
    // ------------------------------------------
    reflex atualizar_saude when: infectado {
        tempo_infeccao <- tempo_infeccao + 1;
        
        if (tempo_infeccao > global.tempo_medio_recuperacao) {
            infectado <- false;
            recuperado <- true;
        }
    }
    
    // ------------------------------------------
    // REFLEXO: CONTAGIAR
    // ------------------------------------------
    reflex contagiar when: (not infectado and not recuperado) {
        list<humanos> vizinhos_infectados <- humanos at_distance 10.0 where (each.infectado);
        
        if not empty(vizinhos_infectados) {
            if flip(global.prob_contagio) {
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
        } else { // Suscetível
            draw circle(2) color: #blue;
        }
        
        if (em_casa) {
            draw square(3) color: #black depth: 0.0;
        }
    }
}