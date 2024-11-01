import { keccak_256 } from "@noble/hashes/sha3"

export default function hexAddress(address /* HexString */) {
    const cleanAddress = address.replace('0x', '').toLowerCase()
    if (cleanAddress.length !== 40) {
        throw new Error('Invalid address length')
    }
    if (!/^[0-9a-f]{40}$/.test(cleanAddress)) {
        throw new Error('Invalid address format')
    }
    const hash = keccak_256(cleanAddress)
    const hexHash = Array.from(hash)
        .map(b => b.toString(16).padStart(2, '0'))
        .join('')
    return '0x' + hexHash
}
