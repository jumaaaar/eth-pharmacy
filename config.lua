Config = {}

Config.PharmaJob = "ambulance"
Config.PrescriptionItem = "prescription"
Config.Pharmacy = {
   ["Locations"] = {
        ["MedicineCabinet"] = { pos = vec3(-511.38, 288.4, 83.39), text = "[E] Get Medicine"},
        ["Tray1"] = { pos = vec3(-506.5, 292.44, 83.39) , text = "[E] Open Tray"},
        ["Tray2"] = { pos = vec3(-506.14, 290.55, 83.39) , text = "[E] Open Tray"},
        ["BossAction"] = {pos = vec3(-505.09, 296.0, 83.39) , text = "[E] Boss Actions"},
        ["BossStash"] = {pos = vec3(-504.51, 298.81, 83.39) , text = "[E] Boss Stash"},
        ["StoreCashier"] = {pos = vec3(-508.85, 292.57, 83.39) , text = "[E] Cashier"},
        ["PaymentCashier"] = {pos = vec3(-509.02, 290.82, 83.39) , text = "[E] Pay"},
        ["PublicStash"] = { pos =vec3(-510.61, 293.41, 83.39) , text = "[E] Stash "}
   },
   ["Stash"] = {
      ["MedicineCabinet"] = {
         id = 'pharma_medcabinet', 
         label = 'Pharmacy Medicine Cabinet', 
         slots = 10, 
         maxWeight = 30000, 
         owner = false
     },
      ["Stash"] = {
         id = 'pharmacy-stash-1', 
         label = 'Pharmacy Stash', 
         slots = 1000, 
         maxWeight = 1000000, 
         owner = false
     },
     ["Tray"] = {
         id = 'pharmacy-tray-1', 
         label = 'Tray', 
         slots = 10, 
         maxWeight = 1000000, 
         owner = false
     },
     ["BossStash"] = {
      id = 'pharmacy-boss-1', 
      label = 'Boss Stash', 
      slots = 1000, 
      maxWeight = 1000000, 
      owner = false
      },
   --   ["BossStash"] = {
   --       setjob = Config.PharmaJob,
   --       joblabel = 'Pharmacy',
   --       society = 'society_pharmacy'
   --   }
   }
}