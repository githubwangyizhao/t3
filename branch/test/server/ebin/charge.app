{application, 'game', [
        {description, "Holle Erlang"},
        {vsn, "0.1.0"},
        {modules, ['charge_app','charge_handler','charge_sup']},
        {registered, []},
        {applications, [kernel,stdlib,cowboy]},
        {mod, {game_app, []}},
        {env, []}
]}.
