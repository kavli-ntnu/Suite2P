%%%% Run Suite2P locally

paths = [...
    'S:\scanimage\82951\28092018\4';...
    'S:\scanimage\82951\28092018\5'
    ];

for i = 1 : length(paths)
    datajoint.run_local(paths(i,:))
end

    