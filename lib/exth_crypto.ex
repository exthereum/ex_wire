defmodule ExthCrypto do
  @moduledoc """
  Handles the general crypto stuff.
  """

  @type public_key :: binary()
  @type private_key :: binary()

  @type curve :: nil
  @type curve_params :: nil

  @doc """
  
  """
  @spec curve_params(public_key) :: curve_params
  def curve_params(public_key) do
    {}
  end

  @doc """

  """
  @spec generate_keypair(curve) :: {public_key, private_key}
  def generate_keypair(curve) do
    
  end
end