defmodule ExWire.Packet.NewBlockHashes do
  @moduledoc """
  Advertises new blocks to the network.

  ```
  **NewBlockHashes** [`+0x01`: `P`, [`hash_0`: `B_32`, `number_0`: `P`], [`hash_1`: `B_32`, `number_1`: `P`], ...]

  Specify one or more new blocks which have appeared on the
  network. To be maximally helpful, nodes should inform peers of all blocks that
  they may not be aware of. Including hashes that the sending peer could
  reasonably be considered to know (due to the fact they were previously
  informed of because that node has itself advertised knowledge of the hashes
  through NewBlockHashes) is considered Bad Form, and may reduce the reputation
  of the sending node. Including hashes that the sending node later refuses to
  honour with a proceeding GetBlockHeaders message is considered Bad Form, and
  may reduce the reputation of the sending node.
  ```
  """

  @behaviour ExWire.Packet

  @type t :: %__MODULE__{
    hashes: [ExWire.Packet.block_hash]
  }

  defstruct [
    :hashes
  ]

  @doc """
  Given a NewBlockHashes packet, serializes for transport over Eth Wire Protocol.

  ## Examples

      iex> %ExWire.Packet.NewBlockHashes{hashes: [{<<5>, 1}, {<<6>, 2}]}
      ...> ExWire.Packet.NewBlockHashes.serialize()
      [[<<5>, 1], [<<6>, 2]]

      iex> %ExWire.Packet.NewBlockHashes{hashes: []}
      ...> ExWire.Packet.NewBlockHashes.serialize()
      []
  """
  @spec serialize(t) :: ExRLP.t
  def serialize(packet=%__MODULE__{}) do
    for {hash, number} <- packet.hashes, do: [hash, number]
  end

  @doc """
  Given an RLP-encoded NewBlockHashes packet from Eth Wire Protocol,
  decodes into a NewBlockHashes struct.

  ## Examples

      iex> ExWire.Packet.NewBlockHashes.deserialize([[<<5>, 1], [<<6>, 2]])
      %ExWire.Packet.NewBlockHashes{hashes: [{<<5>, 1}, {<<6>, 2}]}

      iex> ExWire.Packet.NewBlockHashes.deserialize([])
      ** (RuntimeError) hi
  """
  @spec deserialize(ExRLP.t) :: t
  def deserialize(rlp) do
    hash_lists = [_h|_t] = rlp # must be an array with at least one element
    if Enum.count(hash_lists) > 256, do: raise "Too many hashes"

    hashes = for [hash, number] <- hash_lists, do: {hash, number}

    %__MODULE__{
      hashes: hashes
    }
  end

  @doc """
  Handles a NewBlockHashes message. This is when a peer wants to
  inform us that she knows about new blocks. For now, we'll do nothing.

  ## Examples

      iex> %ExWire.Packet.NewBlockHashes{hashes: [{<<5>, 1}, {<<6>, 2}]}
      ...> ExWire.Packet.NewBlockHashes.handle()
      :ok
  """
  @spec handle(ExWire.Packet.packet) :: ExWire.Packet.handle_response
  def handle(_packet=%__MODULE__{}) do
    # TODO: Do something

    :ok
  end

end
