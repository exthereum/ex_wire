defmodule ExWire.Crypto do
  @moduledoc """
  Helper functions for cryptographic functions of RLPx.
  """

  @type hash :: binary()
  @type signature :: binary()
  @type recovery_id :: integer()

  defmodule HashMismatch do
    defexception [:message]
  end

  @doc """
  Returns a node_id based on a given private key.

  ## Examples

      iex> ExWire.Crypto.node_id(<<1::256>>)
      {:ok, <<121, 190, 102, 126, 249, 220, 187, 172, 85, 160, 98, 149,
              206, 135, 11, 7, 2, 155, 252, 219, 45, 206, 40, 217, 89,
              242, 129, 91, 22, 248, 23, 152, 72, 58, 218, 119, 38, 163,
              196, 101, 93, 164, 251, 252, 14, 17, 8, 168, 253, 23, 180,
              72, 166, 133, 84, 25, 156, 71, 208, 143, 251, 16, 212, 184>>}

      iex> ExWire.Crypto.node_id(<<1>>)
      {:error, "Private key size not 32 bytes"}
  """
  @spec node_id(ExthCrypto.Key.private_key) :: {:ok, ExWire.node_id} | {:error, String.t}
  def node_id(private_key) do
    case ExthCrypto.Signature.get_public_key(private_key) do
      {:ok, <<public_key::binary()>>} -> {:ok, public_key |> ExthCrypto.Key.der_to_raw}
      {:error, reason} -> {:error, to_string(reason)}
    end
  end

  @doc """
  Validates whether a hash matches a given set of data
  via a SHA3 function, or returns `:invalid`.

  ## Examples

      iex> ExWire.Crypto.hash_matches("hi mom", <<228, 33, 19, 6, 43, 181, 255, 41, 190, 203, 202, 88, 58, 103, 207, 48, 227, 138, 243, 96, 69, 152, 95, 32, 48, 43, 200, 207, 79, 64, 252, 60>>)
      :valid

      iex> ExWire.Crypto.hash_matches("hi mom", <<3>>)
      :invalid
  """
  @spec hash_matches(binary(), hash) :: :valid | :invalid
  def hash_matches(data, check_hash) do
    if hash(data) == check_hash do
      :valid
    else
      :invalid
    end
  end

  @doc """
  Similar to `hash_matches/2`, except raises an error if there
  is an invalid hash.

  ## Examples

      iex> ExWire.Crypto.assert_hash("hi mom", <<228, 33, 19, 6, 43, 181, 255, 41, 190, 203, 202, 88, 58, 103, 207, 48, 227, 138, 243, 96, 69, 152, 95, 32, 48, 43, 200, 207, 79, 64, 252, 60>>)
      :ok

      iex> ExWire.Crypto.assert_hash("hi mom", <<3>>)
      ** (ExWire.Crypto.HashMismatch) Invalid hash
  """
  @spec assert_hash(binary(), hash) :: :ok
  def assert_hash(data, check_hash) do
    case hash_matches(data, check_hash) do
      :valid -> :ok
      :invalid -> raise HashMismatch, "Invalid hash"
    end
  end

  @doc """
  Returns the SHA3 hash of a given set of data.

  ## Examples

      iex> ExWire.Crypto.hash("hi mom")
      <<228, 33, 19, 6, 43, 181, 255, 41, 190, 203, 202, 88, 58, 103, 207,
             48, 227, 138, 243, 96, 69, 152, 95, 32, 48, 43, 200, 207, 79, 64,
             252, 60>>

      iex> ExWire.Crypto.hash("hi dad")
      <<239, 144, 71, 138, 41, 74, 120, 227, 61, 182, 176, 178, 193, 220,
             118, 58, 85, 199, 164, 53, 22, 64, 16, 14, 145, 25, 92, 250, 124,
             174, 44, 234>>

      iex> ExWire.Crypto.hash("")
      <<197, 210, 70, 1, 134, 247, 35, 60, 146, 126, 125, 178, 220, 199, 3,
             192, 229, 0, 182, 83, 202, 130, 39, 59, 123, 250, 216, 4, 93, 133,
             164, 112>>
  """
  @spec hash(binary()) :: hash
  def hash(data) do
    ExthCrypto.Hash.Keccak.kec(data)
  end

end