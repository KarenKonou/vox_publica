defmodule VoxPublica.NodeinfoAdapter do
  @behaviour Nodeinfo.Adapter

  def base_url() do
    VoxPublica.Web.Endpoint.url()
  end

  def gather_nodeinfo_data() do
    %{
      name: "Vox Publica",
      version: "0.1.0",
      open_registrations: false,
      user_count: "unknown",
      node_name: "VoxPub",
      node_description: "An instance of Vox Publica",
      federating: true,
      repository: "https://github.com/jjl/vox_publica"
    }
  end
end
