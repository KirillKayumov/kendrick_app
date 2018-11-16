defmodule Kendrick.TaskSpec do
  use ESpec, async: true

  alias Kendrick.Task

  @finished_statuses ~w(
    Acceptance
    closeD
    dOne
    qA
    srEd
  )

  describe "changeset" do
    let(:task) do
      %Task{status: "WIP"}
    end

    subject do
      Task.changeset(task(), attributes())
    end

    describe "finished_status_set_at" do
      context "when no status is passed" do
        let(:attributes) do
          %{title: "New title"}
        end

        it "does NOT have finished_status_set_at in changes" do
          expect(subject().changes) |> not_to(have_key(:finished_status_set_at))
        end
      end

      context "when equal status is passed" do
        let(:attributes) do
          %{status: "WIP"}
        end

        it "does NOT have finished_status_set_at in changes" do
          expect(subject().changes) |> not_to(have_key(:finished_status_set_at))
        end
      end

      context "when not finished status is passed" do
        let(:task) do
          %Task{status: "WIP", finished_status_set_at: {2018, 1, 1}}
        end

        let(:attributes) do
          %{status: "Code Review"}
        end

        it "sets finished_status_set_at to nil" do
          expect(subject().changes)
          |> to(match_pattern(%{finished_status_set_at: nil}))
        end
      end

      Enum.map(@finished_statuses, fn status ->
        context "when #{status} status is passed" do
          let(:attributes) do
            %{status: unquote(status)}
          end

          it "finished_status_set_at to current time" do
            Kendrick.date_time()
            |> Mox.expect(:utc_now, fn -> {2018, 8, 19} end)
            |> Mox.expect(:truncate, fn _, _ -> {2018, 8, 19} end)

            expect(subject().changes)
            |> to(match_pattern(%{finished_status_set_at: {2018, 8, 19}}))
          end
        end
      end)
    end
  end
end
