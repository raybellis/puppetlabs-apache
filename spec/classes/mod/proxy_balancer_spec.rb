# frozen_string_literal: true

require 'spec_helper'

# Helper function for testing the contents of `proxy_balancer.conf`
def balancer_manager_conf_spec(allow_from, manager_path)
  expected = "<Location #{manager_path}>\n"\
             "    SetHandler balancer-manager\n"\
             "    Require ip #{Array(allow_from).join(' ')}\n"\
             "</Location>\n"
  it do
    is_expected.to contain_file('proxy_balancer.conf').with_content(expected)
  end
end

describe 'apache::mod::proxy_balancer', type: :class do
  let :pre_condition do
    [
      'include apache::mod::proxy',
    ]
  end

  it_behaves_like 'a mod class, without including apache'

  context 'default configuration with default parameters' do
    context 'on a Debian OS' do
      include_examples 'Debian 11'

      it { is_expected.to contain_apache__mod('proxy_balancer') }

      it { is_expected.not_to contain_file('proxy_balancer.conf') }
      it { is_expected.not_to contain_file('proxy_balancer.conf symlink') }
    end

    context 'on a RedHat OS' do
      include_examples 'RedHat 8'

      it { is_expected.to contain_apache__mod('proxy_balancer') }

      it { is_expected.not_to contain_file('proxy_balancer.conf') }
      it { is_expected.not_to contain_file('proxy_balancer.conf symlink') }
    end
  end
  context "default configuration with custom parameters $manager => true, $allow_from => ['10.10.10.10','11.11.11.11'], $status_path => '/custom-manager' on a Debian OS" do
    include_examples 'Debian 11'
    let :params do
      {
        manager: true,
        allow_from: ['10.10.10.10', '11.11.11.11'],
        manager_path: '/custom-manager',
      }
    end

    balancer_manager_conf_spec(['10.10.10.10', '11.11.11.11'], '/custom-manager')
  end
end
