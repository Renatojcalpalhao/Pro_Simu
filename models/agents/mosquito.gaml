
species mosquitos parent: agent skills: [moving] { 

	bool infectivo <- false;
	bool incubando <- false;
	int dias_vida <- 0;
	int dias_infeccao <- 0;
	point criadouro <- location;

	// ------------------------------------------------------------
	// Reflexo 1: Atualiza estado biológico
	// ------------------------------------------------------------
	reflex atualizar_estado {
		dias_vida <- dias_vida + 1;

		// Morte natural (~25 dias)
		// CORREÇÃO: Usando global. para a variável movida
		if (dias_vida > global.vida_media_mosquito) { 
			do die;
		}

		// Incubação viral
		if (incubando) {
			dias_infeccao <- dias_infeccao + 1;
			// CORREÇÃO: Usando global. para a variável movida
			if (dias_infeccao >= global.tempo_incubacao_mosquito) { 
				infectivo <- true;
				incubando <- false;
				// CORREÇÃO: Variáveis globais movidas para o DengueSimu.gaml
				global.mosquitos_infectivos <- global.mosquitos_infectivos + 1;
			}
		}
	}

	// ------------------------------------------------------------
	// Reflexo 2: Picada e transmissão
	// ------------------------------------------------------------
	reflex picar {
        // CORREÇÃO: Usando 'humanos' e a qualificação 'each.' (assumindo que 'humanos' foi corrigido)
		humanos alvo <- one_of (humanos at_distance 10.0); 

		if (alvo != nil) {
			// Mosquito infecta humano
			if (infectivo and not alvo.infectado and not alvo.recuperado) { // Usando booleanos corrigidos
                // CORREÇÃO: Usando global. para a variável movida
				if (flip(global.prob_transmissao_mos_hum)) { 
					alvo.infectado <- true;
					alvo.tempo_infeccao <- 0.0;
				}
			}

			// Humano infecta mosquito
			if (alvo.infectado and not infectivo and not incubando) {
                // CORREÇÃO: Usando global. para a variável movida
				if (flip(global.prob_transmissao_hum_mos)) { 
					incubando <- true;
					dias_infeccao <- 0;
					// CORREÇÃO: Variáveis globais movidas para o DengueSimu.gaml
					global.mosquitos_incubando <- global.mosquitos_incubando + 1;
				}
			}
		}
	}

	// ------------------------------------------------------------
	// Reflexo 3: Reprodução
	// ------------------------------------------------------------
	reflex reproducao {
        // CORREÇÃO: Usando global. para a variável movida
		if (flip(global.base_taxa_reproducao_mosquito)) { 
			create mosquitos number: rnd(1, 3) {
				location <- myself.location + {rnd(-10, 10), rnd(-10, 10)};
				criadouro <- myself.criadouro;
			}
		}
	}

	// ------------------------------------------------------------
	// Reflexo 4: Movimento aleatório
	// ------------------------------------------------------------
	reflex mover {
		point destino <- location + {rnd(-5, 5), rnd(-5, 5)};

		if (world.shape overlaps destino) {
			location <- destino;
		}
	}

	// ------------------------------------------------------------
	// ASPECTO VISUAL (Obrigatório para o Display)
	// ------------------------------------------------------------
	aspect base {
		if (infectivo) {
			draw circle(0.8) color: #red;          // mosquitos infectivos
		} else if (incubando) {
			draw circle(0.8) color: #orange;       // incubando
		} else {
			draw circle(0.8) color: #gray;         // normais
		}
	}
}