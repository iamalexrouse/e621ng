module ForumVotesHelper
  def forum_vote_icon(vote)
    case vote.score
    when 1
      vote_up_icon
    when -1
      vote_down_icon
    else
      vote_meh_icon
    end
  end
end
