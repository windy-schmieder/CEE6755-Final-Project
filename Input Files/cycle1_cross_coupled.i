[Mesh]
  file = 'cycle1.msh'
  construct_side_list_from_node_list = true
[]

[GlobalParams]
  displacements = 'disp_x disp_y'
  gravity = '0 0 0'
  biot_coefficient = 1.0
  PorousFlowDictator = dictator
[]

[Variables]
  [porepressure]
    initial_condition = 1e6
  []
  [disp_x]
    initial_condition = 0
    scaling = 1e-5
    order = FIRST
    family = LAGRANGE
  []
  [disp_y]
    initial_condition = 0
    scaling = 1e-5
    order = FIRST
    family = LAGRANGE
  []
[]

[Functions]
  [one_cycle_injection]
    type = ParsedFunction
    expression = '10000 * (315e-6 / (2 * pi * 1 * 20)) * sin(2 * pi * t / 500)'
  []
  [one_cycle_withdrawal]
    type = ParsedFunction
    expression = '-10000 * (315e-6 / (2 * pi * 1 * 20)) * sin(2 * pi * t / 500)'
  []
[]



[FluidProperties]
  [water]
    type = SimpleFluidProperties
    viscosity = 1e-3
    bulk_modulus = 2.1e9
    density0 = 1000
  []
[]

[PorousFlowFullySaturated]
  coupling_type = HydroMechanical
  porepressure = porepressure
  displacements = 'disp_x disp_y'
  fp = water
[]

[Materials]
  [perm]
    type = PorousFlowPermeabilityConst
    permeability = '1E-13 1E-13 0   1E-13 1E-13 0   0 0 0'
  []
  [elasticity]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = 5E9
    poissons_ratio = 0.3
  []
  [strain]
    type = ComputeSmallStrain
  []
  [stress]
    type = ComputeLinearElasticStress
  []
  [porosity]
    type = PorousFlowPorosityConst
    porosity = 0.2
  []
[]

[Kernels]
  [stress_x]
    type = StressDivergenceTensors
    variable = disp_x
    component = 0
    use_displaced_mesh = false
  []
  [stress_y]
    type = StressDivergenceTensors
    variable = disp_y
    component = 1
    use_displaced_mesh = false
  []
  [poro_x]
    type = PorousFlowEffectiveStressCoupling
    variable = disp_x
    component = 0
    use_displaced_mesh = false
  []
  [poro_y]
    type = PorousFlowEffectiveStressCoupling
    variable = disp_y
    component = 1
    use_displaced_mesh = false
  []
[]

[BCs]
  [injection_cycle]
    type = PorousFlowSink
    variable = porepressure
    boundary = inj_well
    flux_function = one_cycle_injection
  []
  [withdrawal_cycle]
    type = PorousFlowSink
    variable = porepressure
    boundary = abs_well
    flux_function = one_cycle_withdrawal
  []
  [constant_output_porepressure]
    type = DirichletBC
    variable = porepressure
    value = 1e6
    boundary = 'left right'
  []
  [fixed_x_displacement]
    type = DirichletBC
    variable = disp_x
    value = 0
    boundary = 'left right'
  []
  [fixed_y_displacement]
    type = DirichletBC
    variable = disp_y
    value = 0
    boundary = bottom
  []
[]

[Executioner]
  type = Transient
  scheme = implicit-euler
  start_time = 0.0
  end_time = 1000
  dt = 0.5
  nl_abs_tol = 1e-5
  solve_type = newton
  nl_max_its = 100
[]

[Preconditioning]
  active = basic
  [basic]
    type = SMP
    full = true
  []
[]


[VectorPostprocessors]
  [pressure_left]
    type = LineValueSampler
    start_point = '0 12.5 0'
    end_point   = '13.5 12.5 0'
    num_points = 30
    variable = porepressure
    warn_discontinuous_face_values = false
    sort_by = x
    execute_on = timestep_end
  []

  [pressure_right]
    type = LineValueSampler
    start_point = '16.5 12.5 0'
    end_point   = '33.5 12.5 0'
    num_points = 30
    variable = porepressure
    warn_discontinuous_face_values = false
    sort_by = x
    execute_on = timestep_end
  []

  [pressure_middle]
    type = LineValueSampler
    start_point = '36.5 12.5 0'
    end_point   = '50 12.5 0'
    num_points = 30
    variable = porepressure
    warn_discontinuous_face_values = false
    sort_by = x
    execute_on = timestep_end
  []

  [disp_left]
    type = LineValueSampler
    start_point = '0 12.5 0'
    end_point   = '13.5 12.5 0'
    num_points = 30
    variable = disp_y
    warn_discontinuous_face_values = false
    sort_by = x
    execute_on = timestep_end
  []

  [disp_middle]
    type = LineValueSampler
    start_point = '16.5 12.5 0'
    end_point   = '33.5 12.5 0'
    num_points = 30
    variable = disp_y
    warn_discontinuous_face_values = false
    sort_by = x
    execute_on = timestep_end
  []

  [disp_right]
    type = LineValueSampler
    start_point = '36.5 12.5 0'
    end_point   = '50 12.5 0'
    num_points = 30
    variable = disp_y
    warn_discontinuous_face_values = false
    sort_by = x
    execute_on = timestep_end
  []
[]

[Outputs]
  file_base = 'CYCLE-FILES-cross_coupled/output'
  exodus = true
  [csv]
    type = CSV
    execute_on = timestep_end
  []
[]
