// Conteúdo FINAL e LIMPO para o ficheiro: agents/area_risco.gaml

species area_risco {

    // Apenas declaração para máxima compatibilidade com o editor GAMA.
    string nome; 
    
    // Inicialização direta no atributo (sintaxe mais robusta para int e float)
    int    nivel_risco <- rnd(1, 5); // 1 (baixo) a 5 (alto)
    int    casos_reportados <- 0;

    aspect base {

        // Gradiente: verde -> vermelho conforme nível de risco
        rgb cor_verde    <- rgb(0, 255, 0);
        rgb cor_vermelho <- rgb(255, 0, 0);
        
        // Fator de 0.0 (verde) a 1.0 (vermelho)
        float fator <- (nivel_risco - 1.0) / 4.0; 

        rgb cor_area <- rgb(
            int(cor_verde.red   + fator * (cor_vermelho.red   - cor_verde.red)),
            int(cor_verde.green + fator * (cor_vermelho.green - cor_verde.green)),
            int(cor_verde.blue  + fator * (cor_vermelho.blue  - cor_verde.blue))
        );

        draw shape color: cor_area border: rgb(0, 0, 0);
    }
}