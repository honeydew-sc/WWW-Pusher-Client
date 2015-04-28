requires "AnyEvent::WebSocket::Client" => "0";
requires "Digest::SHA" => "0";
requires "JSON" => "0";
requires "Moo" => "0";
requires "strict" => "0";
requires "warnings" => "0";

on 'test' => sub {
  requires "AnyEvent" => "0";
  requires "Test::More" => "0";
};

on 'configure' => sub {
  requires "ExtUtils::MakeMaker" => "0";
};

on 'develop' => sub {
  requires "Pod::Coverage::TrustPod" => "0";
  requires "Test::Pod" => "1.41";
  requires "Test::Pod::Coverage" => "1.08";
};
