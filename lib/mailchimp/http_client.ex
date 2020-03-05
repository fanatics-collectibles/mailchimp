defmodule Mailchimp.HTTPClient do
  @moduledoc """
  Poison HTTP Client for Mailchimp
  """

  use HTTPoison.Base

  alias Mailchimp.Config

  @doc """
  Complete / Filter URL

  ### Examples

      iex> Application.put_env(:mailchimp, :api_key, "your apikey-us12")
      iex> Application.delete_env(:mailchimp, :api_version)
      iex> Mailchimp.HTTPClient.process_url("test")
      "https://us12.api.mailchimp.com/3.0/test"

      iex> Application.put_env(:mailchimp, :api_key, "your apikey-us12")
      iex> Application.delete_env(:mailchimp, :api_version)
      iex> Mailchimp.HTTPClient.process_url("https://us12.api.mailchimp.com/3.0/test")
      "https://us12.api.mailchimp.com/3.0/test"

  """
  case Mix.env() do
    :test ->
      def process_url(url) do
        _process_url(url)
      end

    _ ->
      def process_url(url), do: _process_url(url)
  end

  def _process_url(url) do
    root = Config.root_endpoint!()

    cond do
      String.starts_with?(url, root) ->
        url

      String.starts_with?(url, "/") ->
        root <> String.slice(url, 1, 1000)

      true ->
        root <> url
    end
  end

  # Make it easier to mock Responses
  case Mix.env() do
    _ ->
      def process_response_body(body), do: _process_response_body(body)
  end

  defp _process_response_body(body) do
    if body === "" do
      body
    else
      Jason.decode!(body, keys: :atoms)
    end
  end

  @doc """
  Add Auth Header to every request that has none already

  ### Examples

      iex> Application.put_env(:mailchimp, :api_key, "your apikey-us12")
      iex> Mailchimp.HTTPClient.process_request_headers([])
      [{"Authorization", "Basic your apikey-us12"}]

  """
  def process_request_headers(headers) do
    [{"Authorization", "Basic #{Config.api_key!()}"} | headers]
  end
end
