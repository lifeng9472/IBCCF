function initial_net(opts)
% INITIAL_NET: Loading VGG-Net-19

global net;
enableGPU = opts.enableGPU;

net = load(fullfile('model', 'imagenet-vgg-verydeep-19.mat'));

% Remove the fully connected layers and classification layer
net.layers(37+1:end) = [];

if enableGPU
    net = vl_simplenn_move(net, 'gpu');
end

end