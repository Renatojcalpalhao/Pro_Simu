
// Conteúdo do ficheiro: agents/environment.gaml

// =============================================================
// AGENTE AMBIENTE — GERENCIA CLIMA E MÉTRICAS DA SIMULAÇÃO
// =============================================================

species ambiente parent: agent {

    /**
     * Comportamento que se repete a cada passo (dia) da simulação.
     * É responsável por:
     * 1. Atualizar o clima no bloco global.
     * 2. Recalcular e atualizar as métricas globais (infectados, recuperados, etc.).
     */
    reflex atualizar_ambiente every: 1 {

        // 1. Atualiza dados climáticos (Chama a ação definida no bloco global do DengueSimu.gaml)
        ask global {
            do atualizar_dados_ambiente;
        }

        // 2. Atualiza métricas globais da epidemia
        // O agente ambiente acede e modifica as variáveis globais diretamente.
        // Nota: Assume que 'humanos', 'infectado' e 'recuperado' estão definidos nos seus respetivos ficheiros importados.
        global.total_infectados <- count(humanos where (infectado));
        global.total_recuperados <- count(humanos where (recuperado));
        global.total_casos_reportados <- global.total_infectados + global.total_recuperados;

        // 3. Exibe log no console, usando as variáveis globais atualizadas
        write "🌡️ Atualização ambiental: Temp=" + string(global.temperatura_externa)
            + "°C | Umid=" + string(global.umidade)
            + "% | Chuva=" + string(global.precipitacao) + " mm";
    }
}