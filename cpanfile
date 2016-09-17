on configure => sub {
    requires 'Module::CPANfile';
};

on runtime => sub {
    requires 'parent';
    requires 'List::Util';
};
