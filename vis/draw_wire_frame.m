function draw_wire_frame(points,edges)
    % Draw the points first
    plot3(points(:,1),points(:,2),points(:,3),'rx');
    
    hold on;
    
    for edge_index=1:size(edges,1)
        edge_to_draw = edges(edge_index,:);
        plot3(points(edge_to_draw,1),...
            points(edge_to_draw,2),...
            points(edge_to_draw,3),'b');
    end
end
