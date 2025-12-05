;; start_naive.clp - carica MAIN, ENV, case e AgentNaive e avvia
(load "0_Main.clp")
(load "1_Env.clp")
(load "case1_obs_2.clp")    ;; sostituisci con la mappa che vuoi testare
(load "AgentNaive/2_agent.clp")
(load "AgentNaive/3_water.clp")
(load "AgentNaive/4_guess.clp")
(load "AgentNaive/5_random.clp")
(load "AgentNaive/6_solve.clp")
(reset)
(run)
