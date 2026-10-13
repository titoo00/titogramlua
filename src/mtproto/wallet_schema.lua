-- Method identifiers and parameter layouts from RavenGram's pinned Telegram TL schema.
-- This is schema data only; it does not implement authentication or the MTProto transport.
return {
    layer = 230,
    methods = {
        get_state = {name = 'wallet.getState', id = 0xab83b33a, fields = {}},
        get_user_addresses = {name = 'wallet.getUserAddresses', id = 0x5275dfdd, fields = {
            {name = 'force', type = 'true', flag = 0}, {name = 'id', type = 'Vector<InputUser>'},
            {name = 'addresses', type = 'Vector<string>'}}},
        get_transactions = {name = 'wallet.getTransactions', id = 0xa8830a83, fields = {
            {name = 'inbound', type = 'true', flag = 0}, {name = 'outbound', type = 'true', flag = 1},
            {name = 'offset', type = 'string'}, {name = 'limit', type = 'int'}}},
        get_transactions_by_ids = {name = 'wallet.getTransactionsByIDs', id = 0x811ceab6, fields = {
            {name = 'id', type = 'Vector<string>'}}},
        get_transactions_by_msg_hash = {name = 'wallet.getTransactionsByMsgHash', id = 0xa6bb795d, fields = {
            {name = 'msg_hash', type = 'Vector<string>'}}},
        export_secret_phrase = {name = 'wallet.exportSecretPhrase', id = 0x9077c9ac, fields = {
            {name = 'password', type = 'InputCheckPasswordSRP', flag = 0}}},
        fetch_encrypted_secret_phrase_part = {name = 'wallet.fetchEncryptedSecretPhrasePart', id = 0xf53925cf, fields = {
            {name = 'token', type = 'string'}, {name = 'public_key', type = 'bytes'}}},
        replace_wallet = {name = 'wallet.replaceWallet', id = 0xd8c72eec, fields = {
            {name = 'wallet', type = 'InputWalletReplacement'}, {name = 'password', type = 'InputCheckPasswordSRP', flag = 0}}},
        disable_backup = {name = 'wallet.disableBackup', id = 0x0b0bf0da, fields = {
            {name = 'password', type = 'InputCheckPasswordSRP', flag = 0},
            {name = 'new_public_key', type = 'bytes', flag = 1}, {name = 'proof', type = 'WalletOwnershipProof', flag = 2}}},
        get_backup_holder_dcs = {name = 'wallet.getBackupHolderDcs', id = 0xd179d494, fields = {}},
        enable_backup = {name = 'wallet.enableBackup', id = 0x4500c525, fields = {
            {name = 'parts', type = 'Vector<bytes>'}, {name = 'new_public_key', type = 'bytes', flag = 1},
            {name = 'proof', type = 'WalletOwnershipProof', flag = 2}}},
        get_proof_challenge = {name = 'wallet.getProofChallenge', id = 0x2025e697, fields = {}},
        send_transfer = {name = 'wallet.sendTransfer', id = 0xd9e5d9e2, fields = {
            {name = 'data_normal', type = 'bytes'}, {name = 'data_gasless', type = 'bytes', flag = 0},
            {name = 'user_id', type = 'InputUser'}, {name = 'random_id', type = 'long'}}},
        get_gasless_info = {name = 'wallet.getGaslessInfo', id = 0x742df0a1, fields = {}},
        get_existing_wallet_balance = {name = 'wallet.getExistingWaltBalance', id = 0x691f4360, fields = {}},
        get_nfts = {name = 'wallet.getNfts', id = 0x8c12f3a4, fields = {
            {name = 'offset', type = 'string'}, {name = 'limit', type = 'int'}}},
        ton_connect_create_session = {name = 'wallet.tonConnectCreateSession', id = 0xcc931046, fields = {
            {name = 'dapp_client_id', type = 'string'}, {name = 'manifest_url', type = 'string'}}},
        ton_connect_register_key = {name = 'wallet.tonConnectRegisterKey', id = 0x338bcf1c, fields = {
            {name = 'session_id', type = 'long'}, {name = 'client_id', type = 'string'}}},
        ton_connect_submit_connect_result = {name = 'wallet.tonConnectSubmitConnectResult', id = 0xc2c00779, fields = {
            {name = 'error', type = 'true', flag = 0}, {name = 'session_id', type = 'long'},
            {name = 'challenge_answer', type = 'bytes'}, {name = 'body', type = 'bytes'},
            {name = 'trace_id', type = 'string', flag = 1}}},
        ton_connect_get_pending = {name = 'wallet.tonConnectGetPending', id = 0x11aee065, fields = {
            {name = 'dapp_client_id', type = 'string', flag = 0}, {name = 'session_id', type = 'long', flag = 1}}},
        ton_connect_claim_request = {name = 'wallet.tonConnectClaimRequest', id = 0x66b57b41, fields = {
            {name = 'declined', type = 'true', flag = 1}, {name = 'session_id', type = 'long'},
            {name = 'msg_id', type = 'int'}, {name = 'app_request_id', type = 'string'},
            {name = 'challenge_answer', type = 'bytes', flag = 0}}},
        ton_connect_submit_response = {name = 'wallet.tonConnectSubmitResponse', id = 0xfac67d3c, fields = {
            {name = 'session_id', type = 'long'}, {name = 'msg_id', type = 'int'},
            {name = 'body', type = 'bytes'}, {name = 'trace_id', type = 'string', flag = 0}}},
        ton_connect_next_event_id = {name = 'wallet.tonConnectNextEventId', id = 0x775d7244, fields = {
            {name = 'session_id', type = 'long'}}},
        ton_connect_close_session = {name = 'wallet.tonConnectCloseSession', id = 0xd63f61ce, fields = {
            {name = 'session_id', type = 'long'}, {name = 'body', type = 'bytes', flag = 0}}},
        ton_connect_get_sessions = {name = 'wallet.tonConnectGetSessions', id = 0xa7ffb56e, fields = {}}
    }
}
