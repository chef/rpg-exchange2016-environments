# frozen_string_literal: true

# All attributes are set here - default is all enabled.
default['remediation_cis_microsoft_exchange_server_2016_v_1_0_0']['attributes'] = {
    "provider": "CIS",
    "benchmark": "Microsoft Exchange Server 2016",
    "provider_version": "v.1.0.0",
    "global_environment": [
        {
            "name": "MOBILE_MAILBOX_POLICIES",
            "default": "default"
        },
        {
            "name": "REMOTE_DOMAINS",
            "default": "default"
        },
        {
            "name": "OWA_DIRECTORIES",
            "default": "owa (Default Web Site)"
        },
        {
            "name": "REMOTE_DOMAINS",
            "default": "default"
        },
        {
            "name": "EXCHANGE_ADMIN_USERNAME",
            "default": "ExchangeAdmin"
        },
        {
            "name": "EXCHANGE_PASSWORD",
            "default": "ExchPW123!"
        },
        {
            "name": "EXCHANGE_FQDN",
            "default": "exchexample.com"
        },
        {
            "name": "EXCHANGE_SERVER_NAME",
            "default": "exchnodemain"
        },
        {
            "name": "EXCHANGE_MAILBOX_DATABASE_NAMES",
            "default": "DB1"
        },
        {
            "name": "SEND_CONNECTORS",
            "default": "ExampleSendConnector"
        },
        {
            "name": "RECEIVE_CONNECTORS",
            "default": "ExampleReceiveConnectors"
        },
        {
            "name": "EXCHANGE_DIAL_PLANS",
            "default": "ExampleUMDialPlan"
        },
        {
            "name": "UM_MAILBOX_POLICIES",
            "default": "ExampleUMMailboxPolicy"
        },
        {
            "name": "MOBILE_MAILBOX_POLICIES",
            "default": "default"
        }
    ],
    "controls": [
        {
            "id": "CIS_Microsoft_Exchange_Server_2016_1_1",
            "enabled": true
        },
        {
            "id": "CIS_Microsoft_Exchange_Server_2016_1_2",
            "enabled": true
        },
        {
            "id": "CIS_Microsoft_Exchange_Server_2016_1_3",
            "enabled": true
        },
        {
            "id": "CIS_Microsoft_Exchange_Server_2016_1_4",
            "enabled": true
        },
        {
            "id": "CIS_Microsoft_Exchange_Server_2016_1_5",
            "enabled": true
        },
        {
            "id": "CIS_Microsoft_Exchange_Server_2016_1_6",
            "enabled": true
        },
        {
            "id": "CIS_Microsoft_Exchange_Server_2016_1_7",
            "enabled": true
        },
        {
            "id": "CIS_Microsoft_Exchange_Server_2016_1_8",
            "enabled": true
        },
        {
            "id": "CIS_Microsoft_Exchange_Server_2016_1_9",
            "enabled": true
        },
        {
            "id": "CIS_Microsoft_Exchange_Server_2016_1_10",
            "enabled": true
        },
        {
            "id": "CIS_Microsoft_Exchange_Server_2016_1_11",
            "enabled": true
        },
        {
            "id": "CIS_Microsoft_Exchange_Server_2016_1_12",
            "enabled": true
        },
        {
            "id": "CIS_Microsoft_Exchange_Server_2016_1_13",
            "enabled": true
        },
        {
            "id": "CIS_Microsoft_Exchange_Server_2016_1_14",
            "enabled": true
        },
        {
            "id": "CIS_Microsoft_Exchange_Server_2016_1_15",
            "enabled": true
        },
        {
            "id": "CIS_Microsoft_Exchange_Server_2016_1_16",
            "enabled": true
        },
        {
            "id": "CIS_Microsoft_Exchange_Server_2016_1_17",
            "enabled": true
        },
        {
            "id": "CIS_Microsoft_Exchange_Server_2016_1_18",
            "enabled": true
        },
        {
            "id": "CIS_Microsoft_Exchange_Server_2016_2_1",
            "enabled": true
        },
        {
            "id": "CIS_Microsoft_Exchange_Server_2016_2_2",
            "enabled": true
        },
        {
            "id": "CIS_Microsoft_Exchange_Server_2016_2_3",
            "enabled": true
        },
        {
            "id": "CIS_Microsoft_Exchange_Server_2016_2_4",
            "enabled": true
        },
        {
            "id": "CIS_Microsoft_Exchange_Server_2016_2_5",
            "enabled": true
        },
        {
            "id": "CIS_Microsoft_Exchange_Server_2016_2_6",
            "enabled": true
        },
        {
            "id": "CIS_Microsoft_Exchange_Server_2016_2_7",
            "enabled": true,
            "environment": [
                {
                    "name": "PASSWORD_HISTORY",
                    "value": "4"
                }
            ]
        },
        {
            "id": "CIS_Microsoft_Exchange_Server_2016_2_8",
            "enabled": true,
            "environment": [
                {
                    "name": "PASSWORD_EXPIRATION",
                    "default": "90"
                }
            ]
        },
        {
            "id": "CIS_Microsoft_Exchange_Server_2016_2_9",
            "enabled": true,
            "environment": [
                {
                    "name": "MIN_PASSWORD_LENGTH",
                    "default": "4"
                }
            ]
        },
        {
            "id": "CIS_Microsoft_Exchange_Server_2016_2_10",
            "enabled": true
        },
        {
            "id": "CIS_Microsoft_Exchange_Server_2016_2_11",
            "enabled": true
        },
        {
            "id": "CIS_Microsoft_Exchange_Server_2016_2_12",
            "enabled": true
        },
        {
            "id": "CIS_Microsoft_Exchange_Server_2016_2_13",
            "enabled": true
        },
        {
            "id": "CIS_Microsoft_Exchange_Server_2016_2_14",
            "enabled": true
        },
        {
            "id": "CIS_Microsoft_Exchange_Server_2016_2_15",
            "enabled": true
        },
        {
            "id": "CIS_Microsoft_Exchange_Server_2016_2_16",
            "enabled": true
        },
        {
            "id": "CIS_Microsoft_Exchange_Server_2016_2_17",
            "enabled": true
        },
        {
            "id": "CIS_Microsoft_Exchange_Server_2016_2_18",
            "enabled": true
        },
        {
            "id": "CIS_Microsoft_Exchange_Server_2016_2_19",
            "enabled": true
        },
        {
            "id": "CIS_Microsoft_Exchange_Server_2016_2_20",
            "enabled": true,
            "environment": [
                {
                    "name": "MAX_PASSWORD_FAILED_ATTEMPTS",
                    "value": "10"
                }
            ]
        },
        {
            "id": "CIS_Microsoft_Exchange_Server_2016_2_21",
            "enabled": true
        },
        {
            "id": "CIS_Microsoft_Exchange_Server_2016_3_1",
            "enabled": true
        },
        {
            "id": "CIS_Microsoft_Exchange_Server_2016_3_2",
            "enabled": true,
            "manual": true
        },
        {
            "id": "CIS_Microsoft_Exchange_Server_2016_3_3",
            "enabled": true
        },
        {
            "id": "CIS_Microsoft_Exchange_Server_2016_3_4",
            "enabled": true
        },
        {
            "id": "CIS_Microsoft_Exchange_Server_2016_3_5",
            "enabled": true
        },
        {
            "id": "CIS_Microsoft_Exchange_Server_2016_3_6",
            "enabled": true
        },
        {
            "id": "CIS_Microsoft_Exchange_Server_2016_3_7",
            "enabled": true
        },
        {
            "id": "CIS_Microsoft_Exchange_Server_2016_3_8",
            "enabled": true
        },
        {
            "id": "CIS_Microsoft_Exchange_Server_2016_3_9",
            "enabled": true
        },
        {
            "id": "CIS_Microsoft_Exchange_Server_2016_3_10",
            "enabled": true
        },
        {
            "id": "CIS_Microsoft_Exchange_Server_2016_3_11",
            "enabled": true
        }
    ]
}
# Note - the cookbook will perform remediation by default for all controls. Add the below to instead perform a dry-run.
#default['remediation_cis_microsoft_exchange_server_2016_v_1_0_0']['attributes']['dry_run'] = true