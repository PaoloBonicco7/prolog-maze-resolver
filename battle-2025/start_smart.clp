;; start_smart.clp - carica MAIN, ENV, case e AgentSmart e avvia
(load "0_Main.clp")
(load "1_Env.clp")
(load "case1_obs_2.clp")    ;; sostituisci con la mappa che vuoi testare
(load "AgentSmart/2_agent.clp")
(load "AgentSmart/3_water.clp")
(load "AgentSmart/4_guess.clp")
(load "AgentSmart/5_random.clp")
(load "AgentSmart/6_solve.clp")
(reset)
(run)
